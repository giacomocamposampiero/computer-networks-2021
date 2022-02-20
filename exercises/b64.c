#include <stdio.h>
#include <string.h>

int txttob64(char* input, char* output, int input_size, int output_size);

int main() {
    char input[500], output[1100];
    printf("String to be converted: ");
    scanf("%s", input);
    int pos = txttob64(input, output, strlen(input), 1100);
    output[pos] = 0;
    printf("%s\n", output);
}

/**
 * text to b64 conversion
 * @param input : input array
 * @param output : output array
 * @param input_size : input array size
 * @param output_size : output array size
 * @return size of the output array
 */
int txttob64(char* input, char* output, int input_size, int output_size) {
    if(input_size > (output_size/2)) return 0;
    static char encoding_table[] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
                                    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
                                    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
                                    'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
                                    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
                                    'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
                                    'w', 'x', 'y', 'z', '0', '1', '2', '3',
                                    '4', '5', '6', '7', '8', '9', '+', '/'};
    // byte position in the 3-bytes group
    int byte_pos = 0;
    // output array index
    int out_i = 0;
    // for each byte of the input
    for(int i=0; (i<input_size) && (out_i < output_size); i++) {
        switch(byte_pos) {
            // 0x3F == mask 00111111, select only the last 6 bit 
            case 0: 
                // pick only the first 6 bit
                output[out_i] = input[i] >> 2;
                // write the remaining 2 bit in the following byte of the output array
                output[++out_i] = (input[i] << 4) & 0x3F;
                break;
            case 1:
                // write the first 4 bit in the current output byte
                // and the following 4 bit in the following output byte
                output[out_i] += input[i] >> 4;
                output[++out_i] = (input[i] << 2) & 0x3F;
                break;
            case 2: 
                // write the first 2 bit in the current output byte
                // write the last 6 bit in the following output byte
                output[out_i++] += input[i] >> 6;
                output[out_i++] = input[i] & 0x3F;
                break;
        }
        // update byte pos position
        byte_pos = (byte_pos == 2) ? 0 : byte_pos+1;
    }
    if(byte_pos != 0)
        out_i++;
    // convert all the output values to the corresponfing b64 simbols
    for(int i=0; i<out_i; i++) output[i] = encoding_table[output[i]];
    // add padding bytes at the end, if the number of input byte is 
    // not a multiple of three
    while(byte_pos != 0 && byte_pos < 3) {
        output[out_i++] = '=';
        byte_pos++;
    }
    return out_i;
}
