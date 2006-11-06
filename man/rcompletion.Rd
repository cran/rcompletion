\name{rcompletion}
\alias{rcompletion-package}
\alias{rc.settings}
\alias{rc.status}
\alias{rc.getOption}
\alias{rc.options}
\title{Completion for \R using the GNU Readline library}

\description{
  This package provides pseudo-intelligent TAB completion for a readline
  enabled instance of \R when it is run from a terminal (or more
  specifically, an interface which uses readline to accept user input).
  It has no effect on the various GUI interfaces to \R, including ESS and
  the standard Windows interface.
}
  
\usage{

rc.settings(ops, ns, args)
rc.status()

rc.getOption(name)
rc.options(\dots)

}

\arguments{
  \item{ops, ns, args}{
    logical, turning some optional completion features on and off.
    \code{ops} activates completion after the \code{$} and \code{@}
    operators, \code{ns} controls namespace related completions, and
    \code{args} enables completion of function arguments.  All settings
    are turned on by default.  Turn these off if your CPU cycles are
    valuable; you will still retain basic completion on names of objects
    in the search list.  See note below for additional details.
  }
  \item{name, \dots}{ user-settable options.  Currently valid names are
    \code{function.suffix} (default \code{"("}),
    \code{funarg.suffix} (default \code{" = "}) and
    \code{package.suffix} (default \code{"::"}).  See
    \code{\link{options}} for detailed usage description
  }
}

\details{

  The functions listed above, which are the sole exports from this
  package, provide a simple control and query mechanism, but the primary
  reason for using this package is not that, but rather the wonderful
  things that start to happen when you press the TAB key inside \R after
  loading this package.

  There are several types of completion, some of which can be disabled
  using \code{rc.settings}.  The most basic level, which can not be
  turned off once the package is loaded, provides completion on names
  visible on the search path, along with a few special keywords
  (e.g. \code{TRUE}).  This type of completion is not attempted if the
  partial \sQuote{word} (a.k.a. token) being completed is empty (since
  there would be too many completions).  The more advanced types of
  completion are described below.

  
  \describe{

    \item{\bold{Completion after extractors \code{$} and \code{@}}:}{
      When the \code{ops} setting is turned on, completion after
      \code{$} and \code{@} is attempted.  This requires the prefix to
      be evaluated, which is attempted unless it involves an explicit
      function call (implicit function calls involving the use of
      \code{[}, \code{$}, etc \emph{do not} inhibit evaluation).
    }

    \item{\bold{Completion inside namespaces}:}{
      When the \code{ns} setting is turned on, completion inside
      namespaces is attempted when a token is preceded by the \code{::}
      or \code{:::} operators.  Additionally, the basic completion
      mechanism is extended to include attached namespaces, or more
      precisely, \code{foopkg::} becomes a valid completion of
      \code{foo} if the return value of \code{\link{search}()} includes
      the string \code{"package:foopkg"}.

      The completion of package namespaces applies only to attached
      packages, i.e. if \code{MASS} is not attached (whether or not it
      is loaded), \code{MAS} will not complete to \code{MASS::}.
      However, attempted completion \emph{inside} an apparent namespace
      will attempt to load the namespace if it is not already loaded,
      e.g. trying to complete on \code{MASS::fr} will load \code{MASS}
      (but not necessarily attach it) even if it is not already loaded.
    }

    \item{\bold{Completion of function arguments}:}{
      When the \code{args} setting is turned on, completion on function
      arguments is attempted whenever deemed appropriate.  The mechanism
      used will currently fail if the relevant function (at the point
      where completion is requested) was entered on a previous prompt
      (which implies in particular that the current line is being typed
      in response to a continuation prompt, usually \code{+}).  Note
      that separation by newlines is fine.

      The list of possible argument completions that is generated can be
      misleading.  There is no problem for non-generic functions (except
      that \code{\dots} is listed as a completion; this is intentional
      as it signals the fact that the function can accept further
      arguments).  However, for generic functions, it is practically
      impossible to give a reliable argument list without evaluating
      arguments (and not even then, in some cases), which is risky (in
      addition to being difficult to code, which is the real reason it
      hasn't even been tried), especially when that argument is itself
      an inline function call.  Our compromise is to consider arguments
      of \emph{all} currently available methods of that generic.  This
      has two drawbacks.  First, not all listed completions may be
      appropriate in the call currently being constructed.  Second, for
      generics with many methods (like \code{print} and \code{plot}),
      many matches will need to be considered, which may take a
      noticeable amount of time.  Despite these drawbacks, we believe
      this behaviour to be more useful than the only other practical
      alternative, which is to list arguments of the generic only.

      Only S3 methods are currently supported in this fashion.

      Since arguments can be unnamed in \R function calls, other types
      of completion are also appropriate whenever argument completion
      is.  Since there are usually many many more visible objects than
      formal arguments of any particular function, possible argument
      completions are often buried in a bunch of other possibilites.
      However, recall that basic completion is suppressed for blank
      tokens.  This can be useful to list possible arguments of a
      function.  For example, trying to complete \code{seq([TAB]} and
      \code{seq(from = 1, [TAB])} will both list only the arguments of
      \code{seq} (or any of its methods), whereas trying to complete
      \code{seq(length[TAB]} will list both the \code{length.out}
      argument and the \code{length(} function as possible completions.
      Note that no attempt is made to remove arguments already supplied,
      as that would incur a further speed penalty.
    }
  }

  Needless to say, the details above describe intended behaviour;
  whether actual behaviour matches it remains to be seen.

}


\value{
  \code{rc.status} doesn't return anything useful, but prints (using
  \code{\link{str}}) all variables inside an (unexported) environment
  that is used to record the results of the last completion attempt.
  This can be useful for debugging.  For such use, one must resist the
  temptation to use completion when typing the call to \code{rc.status}
  itself, as that then becomes the last attempt by the time the call is
  executed.

  \code{rc.getOption} and \code{rc.options} behave much like
  \code{\link{getOption}} and \code{\link{options}} respectively.
}

\note{
  Completions are determined using pure \R code.  The C code exists
  solely to bind a custom completion generator and to pass information
  between \R and readline.


  This file assumes throughout that the TAB key is bound to the default
  readline \code{complete} function, but this can be modified through an
  \code{inputrc} file.  The details are dicussed in the Bash reference
  manual, under \dQuote{Readline Initialization} (under \dQuote{Command
    Line Editing}) and the subsequent sections.  Conditional constructs
  can use the application name \code{"RCustomCompletion"} for settings
  affecting this package.

  If you are uncomfortable with unsolicited evaluation of pieces of
  code, you should set \code{ops = FALSE}.  Otherwise, trying to
  complete \code{foo@ba} will evaluate \code{foo}, trying to complete
  \code{foo[i, 1:10]$ba} will evaluate \code{foo[i, 1:10]}, etc.  This
  should not be too bad, as explicit function calls (involving
  parentheses) are not evaluated in this manner.  However, this
  \emph{will} affect lazy loaded symbols (and presumably other promise
  type thingies).

  When \code{ns = TRUE}, attached package names (those listed by
  \code{\link{search}}) are completed, but unattached ones are not
  (irrespective of whether they are loaded).  However, trying to
  complete inside a currently unloaded namespace will cause that
  namespace to be loaded.  For example, simply trying to complete
  \code{MASS::fr} will load (but not attach) the \code{MASS} namespace.
  If you do not want this behaviour, set \code{ns = FALSE}.

  Matching function arguments can be slow when the number of possible
  functions is large.  This can be the case for generics with a large
  number of methods, like \code{print}.  This feature can be turned off
  by setting \code{args = FALSE}.
}

\references{
  GNU Readline manual,
  \url{http://cnswww.cns.cwru.edu/php/chet/readline/readline.html}

  GNU Bash manual,
  \url{http://www.gnu.org/software/bash/manual/bashref.html}
}

\author{ Deepayan Sarkar, \email{deepayan.sarkar@r-project.org} }

\keyword{IO}
\keyword{utilities}
