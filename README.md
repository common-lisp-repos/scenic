-*- markdown -*-

# Introduction

A simple GUI toolkit.

         "Hamill: How was the road in?
         Miller: Scenic."
         from "Saving Private Ryan"

It uses Cairo for drawing and SDL as an event source and on-screen
rendering.

# Personal Motivation

I'm a Common Lisp newbie and I want to learn more. A long time ago I
was told that the best way to learn a language is to use it in a
project. This advice helped me everytime I tried using it. This is the
project I use to learn more about Common Lisp.

These are some of the questions I'm exploring in the process:

 * How do I organize a non trivial Common Lisp project into files?
 (where do I place packages, classes, generic methods etc.)
 * Can I still manage working on a project using Emacs? (I got
 very used to Visual Studio lately; there are plenty of things that
 I hate about VS - but I like the project organization/navigation
 tools it offers)
 * How good are Common Lisp debuggers? (and their integration with
 Emacs)
 * How fast is Common Lisp code? How much memory does it need?
 * How easy is it to deploy Common Lisp code?
 * How portable is Common Lisp code (across OSes)?
 * Can I find libraries for what I need (does Quicklisp provide an
 easy way to use Common Lisp libraries)?

So far, the answers to these questions are mostly favorable (or very
favorable). Most of the time, I feel that my brain is the
bottleneck. I don't get that feeling with most other languages (and
when I do get it, I tend to think that the language must share some of
the blame, or that I'm not getting enough for my effort).

# Install

I assume that your Common Lisp implementation has Quicklisp
installed. If not, see http://www.quicklisp.org/beta/ about
instructions on how to install Quicklisp.

The implementations I tested the instructions below are:

 * SBCL (on Ubuntu)
 * CCL (on Ubuntu and Windows XP 32bit and Windows 7 32bit and Windows
 7 64bit)
 * CLISP (on Ubuntu and Windows XP 32bit and Windows 7 32bit)

Scenic uses SDL (http://www.libsdl.org/) and Cairo
(http://cairographics.org/), so you need to have these installed. On
Ubuntu, this is usually already done (and apt-get can help if not). On
Windows, there are some DLLs in `win32-dlls.zip`. They work for
Windows 32bit (tested on Windows XP and Windows 7). Extract the DLL
files in the same directory as the archive. For Windows 64 bit use
`win64-dlls.zip`.

After placing Scenic where it can be picked up by ASDF (such as inside
`~/.local/share/common-lisp/source`), start a Common Lisp
implementation and run:

    (require 'asdf)
    (require 'scenic)
    (in-package :scenic-test)

and then

    (run-auto-tests)

to run all tests in sequence. See the definition of `run-all-tests`
for the list of tests and how to run only one test.

`run-auto-tests` runs all the tests without user intervention,
checking that what happens during the test agrees with a predetermined
scenario. Right now some of the tests may fail, as fonts have slightly
different sizes on systems with different settings (even if the DPI is
the same).

To interactively run all the tests in sequence, use `run-all-tests`.

To interactively run one test, use `test-scene`. For instance,
`(test-scene (buttons))` will run a simple buttons test.

# Other Notes

 1. Since Scenic is tightly linked to Cairo (it uses it for drawing in
 a lot of places), and only lightly coupled to SDL (it uses it to
 render the GUI and to get an event loop - see file `scenic.lisp`),
 it could be changed to use something else instead of SDL (maybe
 OpenGL and GLUT?) for rendering the GUI and processing events.
 2. Right now the code used to load image resources (see
 `scenic-resources.lisp`) hasn't been tested with standalone
 executables and probably requires modification.
