# Moving Average Filter
Sample VHDL project

Moving Average Filter

Takes stream of input data and outputs stream of data after a applying moving average filter.
A window of size 'n', in power of 2, is applied to stream of data and average of the data within the window is calculated to achieve a single output value. The window is shifted with each input data value.


Some further changes or addition that I would have made, with more time to spend, are following:

- Addition of input data valid signal to the entity (for now I am using start signal for that purpose)
- Data width of the accumulator for the summation can be increased so as to avoid the overflows (for now I had kept it to 16bit)
- Testbench could have much better. For now, I just stream-in the input values and I verify the results from the waveform, which could have been better done with the code for input random values.
