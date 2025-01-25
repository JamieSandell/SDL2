package main

import "core:fmt"
import "core:strings"

import sdl "vendor:sdl2"

SCREEN_WIDTH :: 640
SCREEN_HEIGHT :: 480

global_screen_surface : ^sdl.Surface
global_window : ^sdl.Window
global_image : ^sdl.Surface
global_key_press_surfaces : [KeyPressesSurfaces.Total] ^sdl.Surface

KeyPressesSurfaces :: enum {
    Default,
    Up,
    Down,
    Left,
    Right,
    Total
}

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

    for i := 0; i < KeyPressesSurfaces.Total; i += 1 {
        sdl.FreeSurface(global_key_press_surfaces[i])
    }

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
    success := true
    default := "./assets/press.bmp"
    up := "./assets/up.bmp"
    down := "./assets/down.bmp"
    left := "./assets/left.bmp"
    right := "./assets/right.bmp"

    global_key_press_surfaces[KeyPressesSurfaces.Default] = load_surface(default)

    if global_key_press_surfaces[KeyPressesSurfaces.Default] == nil {
        fmt.eprintfln("Failed to load default image: %s", default)
        success = false
    }

    global_key_press_surfaces[KeyPressesSurfaces.Up] = load_surface(up)

    if global_key_press_surfaces[KeyPressesSurfaces.Up] == nil {
        fmt.eprintfln("Failed to load up image: %s", up)
        success = false
    }

    global_key_press_surfaces[KeyPressesSurfaces.Down] = load_surface(down)

    if global_key_press_surfaces[KeyPressesSurfaces.Down] == nil {
        fmt.eprintfln("Failed to load down image: %s", down)
        success = false
    }

    global_key_press_surfaces[KeyPressesSurfaces.Left] = load_surface(left)

    if global_key_press_surfaces[KeyPressesSurfaces.Left] == nil {
        fmt.eprintfln("Failed to load left image: %s", left)
        success = false
    }

    global_key_press_surfaces[KeyPressesSurfaces.Right] = load_surface(right)

    if global_key_press_surfaces[KeyPressesSurfaces.Right] == nil {
        fmt.eprintfln("Failed to load right image: %s", right)
        success = false
    }

    return success
}

load_surface :: proc(path : string) -> ^sdl.Surface {
    loaded_surface := sdl.LoadBMP(strings.clone_to_cstring(path))

    if loaded_surface == nil {
        fmt.eprintfln("Unable to load image %s! SDL error: %s", loaded_surface, sdl.GetError())
    }

    return loaded_surface
}