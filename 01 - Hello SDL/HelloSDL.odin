package main

import "core:fmt"

import sdl "vendor:sdl2"

SCREEN_WIDTH :: 640
SCREEN_HEIGHT :: 480

main :: proc()
{
    fmt.println("Hello world\n")

    // The window we'll be rendering too
    sdl_window : ^sdl.Window

    // The surface contained by the window
    sdl_surface : ^sdl.Surface

    // Initialise SDL
    if (sdl.Init(sdl.INIT_VIDEO) < 0)
    {
        fmt.println("SDL could not initialise! SDL_Error: %s", sdl.GetError())
        return
    }

    // Get window surface
    screen_surface := sdl.GetWindowSurface(sdl_window)

    // Fill the surface white
    sdl.FillRect(sdl_surface, nil, sdl.MapRGB(sdl_surface.format, 0xFF, 0xFF, 0xFF))

    // Update the surface
    sdl.UpdateWindowSurface(sdl_window)

    // Hack to get the window to stay up
    e : sdl.Event
    quit : bool = false

}