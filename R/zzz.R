
.noGenerics <- TRUE

.onLoad <- function(libname, pkgname)
{
    .Call(RCompletionInit)
    ## .Call("RCompletionInit", PACKAGE = "rcompletion")
}

.onUnload <- function(libpath)
    library.dynam.unload("rcompletion", libpath)

