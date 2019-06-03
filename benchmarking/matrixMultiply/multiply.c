#include <fcntl.h>
#include <inttypes.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <sys/mman.h>
#include <time.h>

#define MATRIX_DIM 16

// Address Spaces for FPGA AXI BUS (MMIO Module)
#define FPGA_AXI_BUS  0xC0000000 
#define FPGA_AXI_SPAN 0x00010000

// Address Spaces for TPU
#define TPU_CONTROL_OFFSET    0x000
#define TPU_INPUT_MEM_OFFSET  0x100 // TODO: Verify these offsets w/ Terry
#define TPU_WEIGHT_MEM_OFFSET 0x200
#define TPU_OUTPUT_MEM_OFFSET 0x300

// Command codes for TPU
#define TPU_RESET      0x0000000F
#define TPU_FILL_FIFO  0x00000001
#define TPU_DRAIN_FIFO 0x00000002
#define TPU_MULTIPLY   0x00000003

// Outputs from TPU
#define TPU_FIFO_FILL_DONE  0x00000001
#define TPU_FIFO_DRAIN_DONE 0x00000002
#define TPU_MULTIPLY_DONE   0x00000004

// global variable to hold TPU MMIO Pointers
volatile uint64_t * tpu_control;
volatile uint64_t * tpu_input_mem;
volatile uint64_t * tpu_weight_mem;
volatile uint64_t * tpu_output_mem;

typedef struct 
{
	uint8_t ** data;
} matrix;


void tpu_fill_fifo(uint8_t base_weight_addr)
{
	//printf("Loading FIFO's\n");

	// Tell TPU to fill fifos
	*tpu_control = TPU_FILL_FIFO | (base_weight_addr << 12);
	
	// wait for TPU to be done
	volatile long unsigned int tpu_read_data = 0;
	while (tpu_read_data != TPU_FIFO_FILL_DONE) {
		tpu_read_data = *tpu_control;
		//printf("%lu\n", tpu_read_data);
		tpu_read_data &= TPU_FIFO_FILL_DONE;
	}
	*tpu_control = 0;
	//printf("Done loading FIFO's\n");
}

void tpu_drain_fifo(void)
{
	//printf("Draining FIFO's\n");

	// Tell TPU to drain fifos
	*tpu_control = TPU_DRAIN_FIFO;
	
	// wait for TPU to be done
	volatile long unsigned int tpu_read_data = 0;
	while (tpu_read_data != TPU_FIFO_DRAIN_DONE) {
		tpu_read_data = *tpu_control;
		//printf("%lu\n", tpu_read_data);
		tpu_read_data &= TPU_FIFO_DRAIN_DONE;
	}
	*tpu_control = 0;
	//printf("Done draining FIFO's\n");
}

void tpu_multiply(uint8_t base_input_addr, uint8_t base_output_addr)
{
	//printf("Multiplying\n");

	// Tell TPU to start a multiply
	*tpu_control = TPU_MULTIPLY | (base_input_addr << 12)
			| (base_output_addr << 20);
	
	// wait for TPU to be done
	volatile long unsigned int tpu_read_data = 0;
	while (tpu_read_data != TPU_MULTIPLY_DONE) {
		tpu_read_data = *tpu_control;
		//printf("%lu\n", tpu_read_data);
		tpu_read_data &= TPU_MULTIPLY_DONE;
	}	
	*tpu_control = 0;
	//printf("Done Multiplying\n");
}

void tpu_write_input_mem(uint64_t * data, uint8_t base_addr)
{
	for (int i = 0; i < MATRIX_DIM; i++) {
		*(tpu_input_mem + base_addr + i) = data[i];	
	}
}

void tpu_write_weight_mem(uint64_t * data, uint8_t base_addr)
{
	for (int i = 0; i < MATRIX_DIM; i++) {
		*(tpu_weight_mem + base_addr + i) = data[i];
	}
}

void tpu_read_output_mem(uint64_t * buf, uint8_t base_addr)
{
	for (int i = 0; i < MATRIX_DIM; i++) {
		buf[i] = *(tpu_output_mem + base_addr + i);
	}
}

void tpu_full_suite(uint64_t * inputs, uint64_t * weights, uint64_t * outputs)
{
	tpu_write_input_mem(inputs, 0x00);
	tpu_write_weight_mem(weights, 0x00);
	tpu_fill_fifo(0x00);
	tpu_drain_fifo();
	tpu_multiply(0x00, 0x00);
	tpu_read_output_mem(outputs, 0x00);	
}

void tpu_test_suite(void)
{
	// generate some test matrices to multiply
	uint64_t **inputs = malloc(sizeof(uint64_t*) * MATRIX_DIM * MATRIX_DIM);
	uint64_t **weights = malloc(sizeof(uint64_t*) * MATRIX_DIM * MATRIX_DIM);
	uint64_t **outputs = malloc(sizeof(uint64_t*) * MATRIX_DIM * MATRIX_DIM);
	
	int i, j;
	for (i = 0; i < (MATRIX_DIM * MATRIX_DIM); i++) {
		inputs[i] = malloc(sizeof(uint64_t) * MATRIX_DIM);
		weights[i] = malloc(sizeof(uint64_t) * MATRIX_DIM);
		outputs[i] = malloc(sizeof(uint64_t) * MATRIX_DIM);	
		for (j = 0; j < MATRIX_DIM; j++) {
			inputs[i][j] = (uint64_t) (i * j * i * j);
			weights[i][j] = (uint64_t) (i * i * i * i);
		}
	}

	// reset the TPU
	*tpu_control = TPU_RESET;
	
	printf("Beginning TPU Multiplies...\n\n");
	clock_t begin = clock();
	
	for (i = 0; i < (MATRIX_DIM * MATRIX_DIM); i++) {
		for (j = 0; j < (MATRIX_DIM * MATRIX_DIM); j++) {
			tpu_full_suite(inputs[i], weights[j], outputs[i]);	
		}	
	}
	
	clock_t end = clock();

	double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;


	printf("TPU TOOK %lf\n\n", time_spent);

	// clean up heap
	for (i = 0; i < (MATRIX_DIM * MATRIX_DIM); i++) {
		free(inputs[i]);
		free(weights[i]);
		free(outputs[i]);
	}

	free(weights);
	free(inputs);
	free(outputs);

}

void cpu_multiply(uint8_t ** inputs, uint8_t ** weights, uint8_t ** outputs)
{
	uint16_t sum = 0;
	int i, j, k;
	for (i = 0; i < MATRIX_DIM; i++) {
		for (j = 0; j < MATRIX_DIM; j++) {
			for (k = 0; k < MATRIX_DIM; k++) {
				sum = sum + inputs[i][k] * weights[k][j];
			}	
			
			outputs[i][j] = sum;
			sum = 0;
		}	
	}	
}

void cpu_test_suite(void)
{
	int i, j, k;
	matrix * inputs = malloc(sizeof(matrix) * MATRIX_DIM * MATRIX_DIM); // 256 matrices
	matrix * weights = malloc(sizeof(matrix) * MATRIX_DIM * MATRIX_DIM); // 256 matrices
	matrix * outputs = malloc(sizeof(matrix) * MATRIX_DIM * MATRIX_DIM
						 * MATRIX_DIM * MATRIX_DIM); // 256 * 256 matrices
	
	// Allocate space for matrices (uint8_t double ptr)
	for (i = 0; i < (MATRIX_DIM * MATRIX_DIM); i++) {
		inputs[i].data = malloc(sizeof(uint8_t*) * MATRIX_DIM);
		weights[i].data = malloc(sizeof(uint8_t*) * MATRIX_DIM);
	
		// Allocate space for rows (uint8_t ptr)
		for (j = 0; j < (MATRIX_DIM); j++) {
			inputs[i].data[j] = malloc(sizeof(uint8_t) * MATRIX_DIM);
			weights[i].data[j] = malloc(sizeof(uint8_t) * MATRIX_DIM);	
			
			// Fill in rows
			for (k = 0; k < MATRIX_DIM; k++) {
				inputs[i].data[j][k] = (uint8_t) (i + j + k);
				weights[i].data[j][k] = (uint8_t) (k * j - i);
			}
		}
	}
	
	// Allocate space for output matrices
	for (i = 0; i < (MATRIX_DIM * MATRIX_DIM * MATRIX_DIM * MATRIX_DIM); i++) {
		outputs[i].data = malloc(sizeof(uint8_t*) * MATRIX_DIM);
		
		// Allocate space for rows
		for (j = 0; j < MATRIX_DIM; j++) {
			outputs[i].data[j] = malloc(sizeof(uint8_t) * MATRIX_DIM);	
		}
	}
	
	printf("Beginning CPU Multiplies...\n");

	clock_t begin = clock();

	// Do the multiplications
	for (i = 0; i < (MATRIX_DIM * MATRIX_DIM); i++) {
		for (j = 0; j < (MATRIX_DIM * MATRIX_DIM); j++) {
			cpu_multiply(inputs[i].data, weights[i].data,
					outputs[(i * MATRIX_DIM * MATRIX_DIM) + j].data);
		}
	}	

	clock_t end = clock();
	double time_spent = (double) (end - begin) / CLOCKS_PER_SEC;
	printf("CPU Took: %lf\n", time_spent);
	
}

int main(int argc, char *argv[])
{
	
	// open /dev/mem for mmap()
	int fd;
	if ( (fd = open("/dev/mem", (O_RDWR | O_SYNC))) == -1) {
		fprintf(stderr, "ERROR: could not open \"/dev/mem\"\n");
		exit(1);
	}

	// get virtual addr that maps to physical
	void * tpu_base;
	tpu_base = mmap(NULL, FPGA_AXI_SPAN, (PROT_READ | PROT_WRITE),
			MAP_SHARED, fd, FPGA_AXI_BUS);
	if (tpu_base == MAP_FAILED) {
		fprintf(stderr, "ERROR: mmap() failed...\n");
		exit(1);
	}
	
	// assign base addresses for memory mapped regions
	tpu_control    = (uint64_t*) tpu_base + TPU_CONTROL_OFFSET;	
	tpu_input_mem  = (uint64_t*) tpu_base + TPU_INPUT_MEM_OFFSET;
	tpu_weight_mem = (uint64_t*) tpu_base + TPU_WEIGHT_MEM_OFFSET;
	tpu_output_mem = (uint64_t*) tpu_base + TPU_OUTPUT_MEM_OFFSET;
	
	// begin testing
	tpu_test_suite();
	cpu_test_suite();
	
	
	return 1;
}
