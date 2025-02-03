package main

import "core:fmt"
import "core:strings"

import sdl "vendor:sdl2"
import sdl_image "vendor:sdl2/image"

Texture :: struct {
    texture : ^sdl.Texture,
    height : i32,
    width : i32,
}

SCREEN_WIDTH :: 640
SCREEN_HEIGHT :: 480

global_renderer : ^sdl.Renderer
global_texture_fade_in : Texture
global_texture_fade_out : Texture
global_window : ^sdl.Window

main :: proc() {

    if !init() {
        fmt.eprintln("Failed to init!")
        return
    }

    if !load_media() {
        fmt.eprintln("Failed to load_media")
        return
    }

    alpha : u8 = 255
    e : sdl.Event
    quit := false

    for !quit {
        for sdl.PollEvent(&e) {
            if e.type == sdl.EventType.QUIT {
                quit = true
            }
            else if e.type == sdl.EventType.KEYDOWN {
                #partial switch e.key.keysym.sym {
                    case sdl.Keycode.w : alpha = clamp(alpha + 32, alpha, 255)
                    case sdl.Keycode.s : alpha = clamp(alpha - 32, 0, alpha)
                }
            }
        }

        sdl.SetRenderDrawColor(global_renderer, 0xFF, 0xFF, 0xFF, 0xFF)
        sdl.RenderClear(global_renderer)

        texture_render(global_texture_fade_out, 0, 0, nil)
        texture_set_alpha(global_texture_fade_in, alpha)
        texture_render(global_texture_fade_in, 0, 0, nil)

        sdl.RenderPresent(global_renderer)
    }    

    cleanup_and_quit()
}

cleanup_and_quit :: proc() {
    texture_free(&global_texture_fade_in)
    texture_free(&global_texture_fade_out)
    sdl.DestroyRenderer(global_renderer)
    sdl.DestroyWindow(global_window)
    sdl_image.Quit()
    sdl.Quit()
}

init :: proc() -> bool {
    if sdl.Init(sdl.INIT_VIDEO) < 0 {
        fmt.eprintfln("SDL could not initialise! SDL_Error: %s", sdl.GetError())
        return false
    }

    if !sdl.SetHint(sdl.HINT_RENDER_SCALE_QUALITY, "1") {
        fmt.eprintln("Warning: Linear texture filtering not enabled!")
    }

    global_window = sdl.CreateWindow(
        "Alpha Blending",
        sdl.WINDOWPOS_UNDEFINED,
        sdl.WINDOWPOS_UNDEFINED,
        SCREEN_WIDTH, SCREEN_HEIGHT,
        sdl.WINDOW_SHOWN
    )

    if global_window == nil {
        fmt.eprintfln("Could not create window. SDL_Error: %s", sdl.GetError())
        return false
    }

    global_renderer = sdl.CreateRenderer(global_window, -1, sdl.RENDERER_ACCELERATED)

    if global_renderer == nil {
        fmt.eprintfln("Renderer could not be created! SDL error: %s", sdl.GetError())
        return false
    }

    sdl.SetRenderDrawColor(global_renderer, 0xFF, 0xFF, 0xFF, 0xFF)

    if sdl_image.Init(sdl_image.INIT_PNG) & sdl_image.INIT_PNG != sdl_image.INIT_PNG {
        fmt.eprintfln("sdl_image could not be initialised. sdl_image error: %s", sdl_image.GetError())
        return false
    }

    return true
}

load_media :: proc() -> bool {
    if !texture_load_from_file(&global_texture_fade_in, "./assets/fadein.png") {
        fmt.eprintln("Failed to load fade in colors image.")
        return false
    }

    texture_set_blend_mode(global_texture_fade_in, sdl.BlendMode.BLEND)

    if !texture_load_from_file(&global_texture_fade_out, "./assets/fadeout.png") {
        fmt.eprintln("Failed to load fade out colors image.")
        return false
    }

    return true
}

texture_free :: proc(texture : ^Texture) {
    sdl.DestroyTexture(texture.texture)
    texture.texture = nil
    texture.height = 0
    texture.width = 0
}

texture_load_from_file :: proc(texture: ^Texture, file : string) -> bool {
    texture_free(texture)

    loaded_surface := sdl_image.Load(strings.clone_to_cstring(file))

    if loaded_surface == nil {
        fmt.eprintfln("Unable to load images %s! sdl_image error: %s", file, sdl_image.GetError())
        return false
    }

    sdl.SetColorKey(loaded_surface, 1, sdl.MapRGB(loaded_surface.format, 0, 0xFF, 0xFF))

    new_texture := sdl.CreateTextureFromSurface(global_renderer, loaded_surface)

    if new_texture == nil {
        fmt.eprintfln("Unable to create texture from %s! sdl error: %s", file, sdl.GetError())
        sdl.FreeSurface(loaded_surface)
        return false
    }

    texture.texture = new_texture
    texture.width = loaded_surface.w
    texture.height = loaded_surface.h

    sdl.FreeSurface(loaded_surface)

    return true
}

texture_render :: proc(texture : Texture, x : i32, y : i32, clip : ^sdl.Rect) {
    render_quad := sdl.Rect {
        x = x,
        y = y,
        w = texture.width,
        h = texture.height
    }

    if clip != nil {
        render_quad.w = clip.w
        render_quad.h = clip.h
    }

    sdl.RenderCopy(global_renderer, texture.texture, clip, &render_quad)
}

texture_set_alpha :: proc(texture : Texture, alpha : u8) {
    sdl.SetTextureAlphaMod(texture.texture, alpha)
}

texture_set_blend_mode :: proc(texture : Texture, blend_mode : sdl.BlendMode) {
    sdl.SetTextureBlendMode(texture.texture, blend_mode)
}

texture_set_colour :: proc(texture : Texture, r : u8, g : u8, b : u8) {
    sdl.SetTextureColorMod(texture.texture, r, g, b)
}