#!/usr/bin/env julia

import Pkg
Pkg.activate(@__DIR__)

using WeekendRaytracer

WeekendRaytracer.main(isempty(ARGS) ? "out/image_small.png" : ARGS[1])
