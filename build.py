from build.ab import export, simplerule, filenamesof, filenameof
from build.llvm import llvmrawprogram, llvmclibrary
from build.c import hostcxxprogram, hostclibrary
from build.pkg import package
from glob import glob


def tonyprogram(
    name,
    chunks={},
    sprites={},
    deps=[],
    cflags=[],
    ldflags=[],
):
    args = []
    targets = []
    for k, v in chunks.items():
        args += [k + ":"]
        args += filenamesof(v)
        targets += v
    for k, v in sprites.items():
        r = simplerule(
            name=f"{name}_sprite_{k}",
            ins=[v],
            outs=[f"={name}.o"],
            commands=[
                "$(LD6502) -m moself -r -b binary $[ins[0]] -o $[outs[0]]"
            ],
            label="SPRITE",
        )
        r.materialise()

        args += [k + ":", filenameof(r)]
        targets += [r]

    simplerule(
        name=name + "_chunkfile",
        ins=["tools/genchunks.py"],
        outs=["=generated-chunks.ld"],
        commands=["$(PYTHON) $[ins[0]] " + (" ".join(args)) + " > $[outs[0]]"],
        label="GENCHUNKS",
    )

    llvmrawprogram(
        name=name,
        srcs=targets,
        deps=[f".+{name}_chunkfile", ".+tony_lib"] + deps,
        cflags=cflags + ["-mcpu=mosw65c02"],
        ldflags=ldflags + ["--no-check-sections", "-e0", "-L$[deps[0].dir]"],
        linkscript="./tony.ld",
    )


hostclibrary(
    name="libstb",
    srcs=["third_party/stb/stb_image.c", "third_party/stb/stb_image_write.c"],
    hdrs={
        "stb_image.h": "third_party/stb/stb_image.h",
        "stb_image_write.h": "third_party/stb/stb_image_write.h",
    },
)

package(name="libfmt", package="fmt")
hostcxxprogram(name="dechunker", srcs=["tools/dechunker.cc"], deps=[".+libfmt"])
hostcxxprogram(
    name="despriter",
    srcs=["tools/despriter.cc"],
    deps=[".+libfmt", ".+libstb"],
)

llvmclibrary(
    name="tony_lib",
    hdrs={"tony.inc": "./include/tony.inc", "zif.inc": "./include/zif.inc"},
)

tonyprogram(
    name="romimage",
    chunks={
        "_init": ["src/_init.S"],
        "_main": ["src/_main.S"],
        "_vwrite": ["src/_vwrite.S"],
        "_font": ["src/_font.S"],
        "spritetable": ["src/spritetable.S"],
        "init_screen_009106": ["src/init_screen_009106.S"],
        "init_screen_313021": ["src/init_screen_313021.S"],
        "init_screen_333023": ["src/init_screen_333023.S"],
        "init_screen_d48066": ["src/init_screen_d48066.S"],
        "init_screen_other": ["src/init_screen_other.S"],
        "init_other": ["src/init_other.S"],
    },
    sprites={"sprite_00": ["out.bin"]},
)

export(
    name="all",
    items={
        "tony.img": ".+romimage",
        "bin/dechunker": ".+dechunker",
        "bin/despriter": ".+despriter",
    },
)
