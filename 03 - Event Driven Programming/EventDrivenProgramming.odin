package main

import "core:fmt"

import sdl "vendor:sdl2"

SCREEN_WIDTH :: 640
SCREEN_HEIGHT :: 480

global_screen_surface : ^sdl.Surface
global_window : ^sdl.Window
global_image : ^sdl.Surface

main :: proc() {

    if !init() {
        fmt.eprintln("Failed to init!")
        return
    }

    if !load_media() {
        fmt.eprintln("Failed to load media")
    }

    e : sdl.Event
    quit := false

    for !quit {
        for sdl.PollEvent(&e) != false {
            if e.type == sdl.EventType.QUIT {
                quit = true
            }
        }
        
        sdl.BlitSurface(global_image, nil, global_screen_surface, nil)
        sdl.UpdateWindowSurface(global_window)
    }    

    cleanup_and_quit()
}

cleanup_and_quit :: proc() {
    sdl.FreeSurface(global_image)
    sdl.DestroyWindow(global_window)
    sdl.Quit() // frees the memory for the main window surface along with calling various subsystem Quits.
}

init :: proc() -> bool {
    if sdl.Init(sdl.INIT_VIDEO) < 0 {
        fmt.eprintfln("SDL could not initialise! SDL_Error: %s", sdl.GetError())
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
        fmt.eprintfln("Could not create window. SDL_Error: %s", sdl.GetError())
        return false
    }

    global_screen_surface = sdl.GetWindowSurface(global_window)

    return true
}

load_media :: proc() -> bool {
    hello_world : cstring = "./x.bmp"
    global_image = sdl.LoadBMP(hello_world)

    if global_image == nil {
        fmt.eprintfln("Unable to load image %s! SDL Error: %s", hello_world, sdl.GetError())
        return false
    }

    return true
}