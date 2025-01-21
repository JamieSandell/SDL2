package main

import "core:fmt"

import sdl "vendor:sdl2"

SCREEN_WIDTH :: 640
SCREEN_HEIGHT :: 480

global_screen_surface : ^sdl.Surface
global_window : ^sdl.Window
global_image : ^sdl.Surface

main :: proc() {

    init()
    sdl.UpdateWindowSurface(global_window)

    e : sdl.Event

    for {
        sdl.PollEvent(&e)

        if e.type == sdl.EventType.QUIT {
            break
        }
    }
}

init :: proc() -> bool {
    if sdl.Init(sdl.INIT_VIDEO) < 0 {
        fmt.eprintln("SDL could not initialise! SDL_Error: %s", sdl.GetError())
        return false
    }

    global_window = sdl.CreateWindow(
        "Getting an Image on the Screen",
        sdl.WINDOWPOS_UNDEFINED,
        sdl.WINDOWPOS_UNDEFINED,
        SCREEN_WIDTH, SCREEN_HEIGHT,
        sdl.WINDOW_SHOWN
    )

    if global_window == nil {
        fmt.eprintln("Could not create window. SDL_Error: %s", sdl.GetError())
        return false
    }

    global_screen_surface = sdl.GetWindowSurface(global_window)

    return true
}

cleanup_and_quit :: proc() {
    sdl.FreeSurface(global_image)
    sdl.DestroyWindow(global_window)
    sdl.Quit() // frees the memory for the main window surface along with calling various subsystem Quits.
}