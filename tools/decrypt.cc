#include <fmt/format.h>
#include <fstream>
#include <vector>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, const char* argv[])
{
    std::fstream flashrom(argv[1]);
    std::vector<uint8_t> data(std::istreambuf_iterator<char>{flashrom}, {});

    uint8_t key =
        ((data[0x09 + 0] - data[0x09 + 1] | data[0x09 + 2]) ^ data[0x09 + 3]) +
            data[0x09 + 4] &
        data[0x09 + 5];
    fmt::print("key is 0x{:02x}\n", key);

    if (((data[0x0f + 0] ^ key) != data[9 + 0]) ||
        ((data[0x0f + 1] ^ key) != data[9 + 1]) ||
        ((data[0x0f + 2] ^ key) != data[9 + 2]) ||
        ((data[0x0f + 3] ^ key) != data[9 + 3]) ||
        ((data[0x1f + 0] ^ key) != data[9 + 4]) ||
        ((data[0x1f + 1] ^ key) != data[9 + 5]) ||
        ((data[0x23 + 0] ^ key) != 't') || ((data[0x23 + 1] ^ key) != 'o') ||
        ((data[0x23 + 2] ^ key) != 'n') || ((data[0x23 + 3] ^ key) != 'y'))
    {
        fmt::print(
            "key doesn't pass validation --- is this a real tony flash "
            "image?\n");
        exit(1);
    }

    for (uint8_t& b : data)
        b ^= key;
    data[0x09 + 0] = data[0x09 + 1] = data[0x09 + 2] = data[0x09 + 3] =
        data[0x09 + 4] = data[0x09 + 5] = data[0x0f + 0] = data[0x0f + 1] =
            data[0x0f + 2] = data[0x0f + 3] = data[0x1f + 0] = data[0x1f + 1] =
                data[0x1f + 2] = data[0x1f + 3] = 0;

    fmt::print("writing decrypted file to '{}'\n", argv[2]);
    std::fstream ofs(argv[2], std::fstream::out | std::fstream::binary);
    for (uint8_t b : data)
        ofs.put(b);

    return 0;
}