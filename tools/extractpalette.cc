#include <fmt/format.h>
#include <fstream>
#include <map>
#include <set>
#include <vector>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

int main(int argc, const char** argv)
{
    std::fstream maskrom(argv[1]);
    const std::vector<uint8_t> rom(std::istreambuf_iterator<char>{maskrom}, {});

    uint8_t palette[256][3];
    for (int i = 0; i < 256; i++)
    {
        uint16_t rgb16 = rom[0x1357 + i] | (rom[0x1257 + i] << 8);
        float b = (float)(rgb16 & 0x1f) / (float)0x1f;
        float g = (float)((rgb16 >> 5) & 0x3f) / (float)0x3f;
        float r = (float)((rgb16 >> 11) & 0x1f) / (float)0x1f;
        fmt::print("{{0x{:02x}, 0x{:02x}, 0x{:02x}}},\n", (int)(255.0 * r), (int)(255.0 * g), (int)(255.0 * b));
    }

    return 0;
}
