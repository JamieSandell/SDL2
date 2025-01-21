package main

import "core:fmt"

import sdl "vendor:sdl2"

SCREEN_WIDTH :: 640
SCREEN_HEIGHT :: 480

main :: proc() {
    if sdl.Init(sdl.INIT_VIDEO) < 0 {
        fmt.eprintln("SDL could not initialise! SDL_Error: %s", sdl.GetError())
        return
    }

    window := sdl.CreateWindow(
        "Hello World",
        sdl.WINDOWPOS_UNDEFINED,
        sdl.WINDOWPOS_UNDEFINED,
        SCREEN_WIDTH, SCREEN_HEIGHT,
        sdl.WINDOW_SHOWN
    )

    if window == nil {
        fmt.eprintln("Could not create window. SDL_Error: %s", sdl.GetError())
    }

    screen_surface := sdl.GetWindowSurface(window)

    sdl.FillRect(screen_surface, nil, sdl.MapRGB(screen_surface.format, 0xFF, 0xFF, 0xFF))

    sdl.UpdateWindowSurface(window)

    e : sdl.Event

    for {
        sdl.PollEvent(&e)

        if e.type == sdl.EventType.QUIT {
            break
        }
    }
}