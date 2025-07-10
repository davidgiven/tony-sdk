from build.ab import export
from build.llvm import llvmrawprogram, llvmclibrary

llvmclibrary(
    name="tony_lib",
    hdrs={
        "tony.inc": "./include/tony.inc"
    })

llvmrawprogram(
    name="romimage",
    srcs=["src/init.S", "src/main.S"],
    deps=[".+tony_lib"],
    ldflags=["--no-check-sections"],
    linkscript="./tony.ld",
)


export(
    name="all",
    items={
        "tony.img": ".+romimage"
    }
)
