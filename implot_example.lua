local ffi = require"ffi"
local inspect = require 'inspect'
local wav = require'luawav'
-- wget https://github.com/rxi/json.lua/raw/master/json.lua
local json = require "json"


--from https://github.com/sonoro1234/LuaJIT-SDL2
local sdl = require"sdl2_ffi"
--just to get gl functions
-- from https://github.com/sonoro1234/LuaJIT-GLFW
local gllib = require"gl"
gllib.set_loader(sdl)
local gl, glc, glu, glext = gllib.libraries()

local json_file = arg[1]
local wav_file = arg[2]
if wav_file == nil then os.exit(1) end
if json_file == nil then os.exit(1) end

local ig = require"imgui.sdl"

if (sdl.init(sdl.INIT_VIDEO+sdl.INIT_TIMER) ~= 0) then

    print(string.format("Error: %s\n", sdl.getError()));
    return -1;
end

sdl.gL_SetAttribute(sdl.GL_CONTEXT_PROFILE_MASK, sdl.GL_CONTEXT_PROFILE_CORE);
sdl.gL_SetAttribute(sdl.GL_DOUBLEBUFFER, 1);
sdl.gL_SetAttribute(sdl.GL_DEPTH_SIZE, 24);
sdl.gL_SetAttribute(sdl.GL_STENCIL_SIZE, 8);
sdl.gL_SetAttribute(sdl.GL_CONTEXT_MAJOR_VERSION, 3);
sdl.gL_SetAttribute(sdl.GL_CONTEXT_MINOR_VERSION, 1);
local current = ffi.new("SDL_DisplayMode[1]")
sdl.getCurrentDisplayMode(0, current);
local window = sdl.createWindow("ImGui SDL2+OpenGL3 example", sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED, 1600, 500, sdl.WINDOW_OPENGL+sdl.WINDOW_RESIZABLE); 
local gl_context = sdl.gL_CreateContext(window);
sdl.gL_SetSwapInterval(1); -- Enable vsync

local ig_Impl = ig.Imgui_Impl_SDL_opengl3()

ig_Impl:Init(window, gl_context)

local igio = ig.GetIO()

ig.ImPlot_CreateContext()

local f = io.open(json_file)
local rx2_json = json.decode(f:read("*all"))
print(inspect(rx2_json))

local meta_and_samples = wav.drwav_open_and_read_pcm_frames_f32(wav_file)
print(inspect(meta_and_samples, {depth=1}))
local length_samples = #meta_and_samples.samples / meta_and_samples.channels
print(#meta_and_samples.samples, length_samples, (length_samples) / meta_and_samples.sampleRate)
local sound_y = ffi.new("float[?]", length_samples)
local sound_x = ffi.new("float[?]", length_samples)
-- local sound_x = ffi.new("float[?]", length_samples)
for s=1, length_samples do
    sound_y[s] = meta_and_samples.samples[s*2]
    sound_x[s] = s
end

local slices_y = ffi.new("float[?]", length_samples)
for s,slice in ipairs(rx2_json.slices_list) do
    slices_y[slice.start] = 1.0
    slices_y[slice.start+1] = -1.0
end


local done = false;
local showdemo = ffi.new("bool[1]",false)
while (not done) do
    --SDL_Event 
    local event = ffi.new"SDL_Event"
    while (sdl.pollEvent(event) ~=0) do
        ig.lib.ImGui_ImplSDL2_ProcessEvent(event);
        if (event.type == sdl.QUIT) then
            done = true;
        end
        if (event.type == sdl.WINDOWEVENT and event.window.event == sdl.WINDOWEVENT_CLOSE and event.window.windowID == sdl.getWindowID(window)) then
            done = true;
        end
    end
    --standard rendering
    sdl.gL_MakeCurrent(window, gl_context);
    gl.glViewport(0, 0, igio.DisplaySize.x, igio.DisplaySize.y);
    gl.glClear(glc.GL_COLOR_BUFFER_BIT)

    ig_Impl:NewFrame()
    
    ig.SetNextWindowPos(ig.ImVec2(0,0))
    ig.SetNextWindowSize(ig.ImVec2(1600,500))
    ig.Begin("Wave file", nil, ig.lib.ImGuiWindowFlags_NoCollapse+ig.lib.ImGuiWindowFlags_NoResize+ig.lib.ImGuiWindowFlags_NoMove)
    
    if ig.Button"Hello" then
        print"Hello World!!"
    end
    ig.Checkbox("Show demo", showdemo)
    if showdemo[0] then
        ig.ShowDemoWindow(showdemo)
        ig.ImPlot_ShowDemoWindow(showdemo)
    end
    
    if (ig.ImPlot_BeginPlot(wav_file)) then
        -- ig.ImPlot_PlotLine("x^2", xs2, ys2, 11);
        ig.ImPlot_PlotLine("Sound", sound_x, sound_y, length_samples);
        ig.ImPlot_PlotLine("Slices", sound_x, slices_y, length_samples);
        ig.ImPlot_EndPlot();
    end
    ig.End()
    
    ig_Impl:Render()
    sdl.gL_SwapWindow(window);
end

ig.ImPlot_DestroyContext()
-- Cleanup
ig_Impl:destroy()

sdl.gL_DeleteContext(gl_context);
sdl.destroyWindow(window);
sdl.quit();

