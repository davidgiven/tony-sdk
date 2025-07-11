from build.ab import export, simplerule, filenamesof
from build.llvm import llvmrawprogram, llvmclibrary


def tonyprogram(
    name,
    chunks={},
    deps=[],
    cflags=[],
    ldflags=[],
):
    args = []
    for k, v in chunks.items():
        args += [k + ":"]
        args += filenamesof(v)

    simplerule(
        name=name + "_chunkfile",
        ins=["tools/genchunks.py"],
        outs=["=generated-chunks.ld"],
        commands=["$(PYTHON) $[ins[0]] " + (" ".join(args)) + " > $[outs[0]]"],
        label="GENCHUNKS",
    )

    llvmrawprogram(
        name=name,
        srcs=[inner for outer in chunks.values() for inner in outer],
        deps=[f".+{name}_chunkfile", ".+tony_lib"] + deps,
        cflags=cflags+["-mcpu=mosr65c02"],
        ldflags=ldflags + ["--no-check-sections", "-e0", "-L$[deps[0].dir]"],
        linkscript="./tony.ld",
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
        "init_screen_009106": ["src/init_screen_009106.S"],
        "init_screen_313021": ["src/init_screen_313021.S"],
        "init_screen_333023": ["src/init_screen_333023.S"],
        "init_screen_d48066": ["src/init_screen_d48066.S"],
        "init_screen_other": ["src/init_screen_other.S"],
        "init_other": ["src/init_other.S"],
    },
)

export(name="all", items={"tony.img": ".+romimage"})
