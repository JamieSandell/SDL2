package main

import "core:fmt"
import "core:strings"

import sdl "vendor:sdl2"

SCREEN_WIDTH :: 640
SCREEN_HEIGHT :: 480

global_current_surface : ^sdl.Surface
global_key_press_surfaces : [KeyPressesSurfaces.Total] ^sdl.Surface
global_screen_surface : ^sdl.Surface
global_window : ^sdl.Window

KeyPressesSurfaces :: enum {
    Default,
    Up,
    Down,
    Left,
    Right,
    Total\
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
    global_current_surface = global_key_press_surfaces[KeyPressesSurfaces.Default]

    for !quit {
        for sdl.PollEvent(&e) {
            if e.type == sdl.EventType.QUIT {
                quit = true
            }
            else if e.type == sdl.EventType.KEYDOWN {
                #partial switch e.key.keysym.sym {
                    case sdl.Keycode.UP:
                        global_current_surface = global_key_press_surfaces[KeyPressesSurfaces.Up]
                    case sdl.Keycode.DOWN:
                        global_current_surface = global_key_press_surfaces[KeyPressesSurfaces.Down]
                    case sdl.Keycode.LEFT:
                        global_current_surface = global_key_press_surfaces[KeyPressesSurfaces.Left]
                    case sdl.Keycode.RIGHT:
                        global_current_surface = global_key_press_surfaces[KeyPressesSurfaces.Right]
                    case:
                        global_current_surface = global_key_press_surfaces[KeyPressesSurfaces.Default]
                }
            }
        }
        
        sdl.BlitSurface(global_current_surface, nil, global_screen_surface, nil)
        sdl.UpdateWindowSurface(global_window)
    }    

    cleanup_and_quit()
}

cleanup_and_quit :: proc() {
    for surface in global_key_press_surfaces {
        sdl.FreeSurface(surface)
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