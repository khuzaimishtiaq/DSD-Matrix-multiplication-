import serial
import time
import numpy as np

def send_matrix_and_receive():
    """
    Sends two fixed 3x3 matrices to the FPGA and receives the resulting 3x3 matrix.
    Includes appropriate delays for UART communication.
    """
    size = 3  # Fixed matrix size

    # Record start time
    overall_start_time = time.time()

    # Configure serial port
    ser = serial.Serial('COM5', 9600, timeout=1)

    # Send matrix size (3x3)
    print(f"Sending matrix size: {size}")
    ser.write(bytes([size]))  # Send matrix size as a byte

    # Generate random test matrices (values between 1 and 10)
    matrix_A = np.random.randint(1, 11, (size, size))
    matrix_B = np.random.randint(1, 11, (size, size))

    # Send Matrix A
    print("Sending Matrix A:")
    for value in matrix_A.flatten():
        print(f"Sending value: {value}")
        ser.write(bytes([int(value)]))
        time.sleep(0.5)  # Delay for FPGA to process each byte

    # Send Matrix B
    print("\nSending Matrix B:")
    for value in matrix_B.flatten():
        print(f"Sending value: {value}")
        ser.write(bytes([int(value)]))
        time.sleep(0.5)  # Delay for FPGA to process each byte

    # Prepare to receive result matrix
    result = []
    expected_size = size * size
    print(f"\nReceiving result matrix (waiting for {expected_size} values)...")

    # Timeout after 10 seconds if not complete
    timeout = time.time() + 10  # 10-second timeout
    while len(result) < expected_size and time.time() < timeout:
        if ser.in_waiting:  # Check if there's data to read
            byte = ser.read(1)  # Read one byte
            if byte:
                value = ord(byte)  # Convert the byte to an integer
                result.append(value)
                print(f"Received: {value}")
                time.sleep(0.1)  # Delay for FPGA to send the next byte

    ser.close()

    # Check and reshape result
    if len(result) == expected_size:
        result_matrix = np.array(result).reshape((size, size))
        print("\nResult matrix:")
        print(result_matrix)

        # Actual matrix multiplication result
        actual_result = np.dot(matrix_A, matrix_B)
        print("\nActual Result of Matrix Multiplication:")
        print(actual_result)
    else:
        print(f"Error: Received {len(result)} values, expected {expected_size}")

    # Record end time
    overall_end_time = time.time()

    # Report total times
    total_overall = overall_end_time - overall_start_time

    print(f"\n--- Timing Report ---")
    print(f"Total time (send + receive + any delays): {total_overall:.4f} seconds")

# Main program (fixed size of 3x3 matrix)
if __name__ == "__main__":
    print("Matrix size fixed at 3x3.")
    send_matrix_and_receive()
