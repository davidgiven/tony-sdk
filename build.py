from build.ab import export, simplerule, filenamesof, filenameof
from build.llvm import llvmrawprogram, llvmclibrary
from build.c import hostcxxprogram, hostclibrary
from build.pkg import package
from build.utils import stripext
from glob import glob

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
    name="extractpalette", srcs=["tools/extractpalette.cc"], deps=[".+libfmt"]
)
hostcxxprogram(
    name="deresourcer",
    srcs=["tools/deresourcer.cc", "include/palette.h"],
    deps=[".+libfmt", ".+libstb"],
)
hostcxxprogram(
    name="spritify",
    srcs=["tools/spritify.cc", "include/palette.h"],
    deps=[".+libfmt", ".+libstb"],
)


def tonyprogram(name, chunks={}, resources={}, deps=[], cflags=[], ldflags=[]):
    allresources = " ".join(resources.keys())
    r = simplerule(
        name=name + "_rsrc",
        ins=["tools/genresources.py"],
        outs=["=resourcetable.S"],
        commands=[f"$(PYTHON) $[ins[0]] {allresources} > $[outs[0]]"],
        label="GENRESOURCES",
    )
    chunks = chunks | {"resourcetable": [r]}

    args = []
    targets = []
    for k, v in chunks.items():
        args += [k + ":"]
        args += filenamesof(v)
        targets += v
    for k, v in resources.items():
        r = simplerule(
            name=f"{name}_sprite_{k}",
            ins=[v],
            outs=[f"={name}_sprite_{k}.o"],
            deps=[".+spritify"],
            commands=[
                "$[deps[0]] $[ins[0]] $[dir]/temp.bin",
                "$(LD6502) -m moself -r -b binary $[dir]/temp.bin -o $[outs[0]]",
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


llvmclibrary(
    name="tony_lib",
    hdrs={"tony.inc": "./include/tony.inc", "zif.inc": "./include/zif.inc"},
)

# This is the rule which needs changing to actually write code.

tonyprogram(
    name="romimage",
    # Each item here produces a single chunk. Each one can be made from multiple
    # source files.
    chunks={
        "_init": ["src/_init.S"],
        "_main": ["src/_main.S"],
        "_vwrite": ["src/_vwrite.S"],
        "_font": ["src/_font.S"],
        "init_screen_009106": ["src/init_screen_009106.S"],
        "init_screen_313021": ["src/init_screen_313021.S"],
        "init_screen_333023": ["src/init_screen_333023.S"],
        "init_screen_d48066": ["src/init_screen_d48066.S"],
        "init_screen_other": ["src/init_screen_other.S"],
        "init_other": ["src/init_other.S"],
    },
    # This compiles all the files in the rsrc directory as resources.
    resources={stripext(f): f"rsrc/{f}" for f in glob("*", root_dir="rsrc")},
)

export(
    name="all",
    items={
        "tony.img": ".+romimage",
        "bin/dechunker": ".+dechunker",
        "bin/deresourcer": ".+deresourcer",
        "bin/extractpalette": ".+extractpalette",
        "bin/spritify": ".+spritify",
    },
)
