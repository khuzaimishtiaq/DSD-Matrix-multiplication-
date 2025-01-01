import serial
import time

# Configuration for the UART
UART_PORT = "COM5"  # Replace with the correct COM port (e.g., /dev/ttyUSB0 for Linux)
BAUD_RATE = 9600  # Match the Verilog design's baud rate
DATA_BITS = serial.EIGHTBITS  # Data frame size
PARITY = serial.PARITY_NONE  # No parity
STOP_BITS = serial.STOPBITS_ONE  # One stop bit
TIMEOUT = 1  # Timeout for read in seconds


def test_uart():
    try:
        # Open the serial port
        uart = serial.Serial(
            port=UART_PORT,
            baudrate=BAUD_RATE,
            bytesize=DATA_BITS,
            parity=PARITY,
            stopbits=STOP_BITS,
            timeout=TIMEOUT
        )

        if uart.is_open:
            print(f"Opened UART on {UART_PORT} with baud rate {BAUD_RATE}")

        # Test data to send
        test_data = b'A'
        print(f"Sending: {test_data}")

        # Write the test data
        uart.write(test_data)

        print(f"Receiving:")
        # Wait a short while for the data to loop back (or for FPGA to process)
        time.sleep(0.5)

        # Read the data back
        received_data = uart.read(len(test_data))
        print(f"Received: {received_data}")

        # Check if the received data matches the sent data
        if received_data == test_data:
            print("Test Passed: Sent and received data match.")
        else:
            print("Test Failed: Sent and received data do not match.")

        # Close the serial port
        uart.close()

    except serial.SerialException as e:
        print(f"Error opening or communicating with UART: {e}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


if __name__ == "__main__":
    test_uart()
