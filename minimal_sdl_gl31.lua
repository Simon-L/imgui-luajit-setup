local ffi = require"ffi"

--from https://github.com/sonoro1234/LuaJIT-SDL2
local sdl = require"sdl2_ffi"
--just to get gl functions
-- from https://github.com/sonoro1234/LuaJIT-GLFW
local gllib = require"gl"
gllib.set_loader(sdl)
local gl, glc, glu, glext = gllib.libraries()

local ig = require"imgui.sdl"

if (sdl.init(sdl.INIT_VIDEO+sdl.INIT_TIMER+sdl.INIT_GAMECONTROLLER) ~= 0) then
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
    local window = sdl.createWindow("ImGui SDL2+OpenGL3 example", sdl.WINDOWPOS_CENTERED, sdl.WINDOWPOS_CENTERED, 640, 480, sdl.WINDOW_OPENGL+sdl.WINDOW_RESIZABLE); 
    local gl_context = sdl.gL_CreateContext(window);
    sdl.gL_SetSwapInterval(1); -- Enable vsync
    
    local ig_Impl = ig.Imgui_Impl_SDL_opengl3()
    
    ig_Impl:Init(window, gl_context)

    local igio = ig.GetIO()
    igio.ConfigFlags = ig.lib.ImGuiConfigFlags_NavEnableKeyboard + igio.ConfigFlags 
    igio.ConfigFlags = ig.lib.ImGuiConfigFlags_NavEnableGamepad + igio.ConfigFlags
    
    -- For R36S
    local remap = "1900c3ea010000000100000001010000,odroidgo3_joypad,a:b1,b:b0,dpdown:b13,dpleft:b14,+lefty:+a1,-leftx:-a0,+leftx:+a0,-lefty:-a1,leftshoulder:b4,leftstick:b16,lefttrigger:b6,dpright:b15,+righty:+a3,-rightx:-a2,+rightx:+a2,-righty:-a3,rightshoulder:b5,rightstick:b10,righttrigger:b7,back:b8,start:b9,dpup:b12,x:b2,y:b3,guide:b11,platform:Linux"
    local res = sdl.SDL_GameControllerAddMapping(remap)
    
    local done = false;
    local showdemo = ffi.new("bool[1]",true)
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
        
        
        if ig.Button"Hello" then
            print"Hello World!!"
        end
        ig.ShowDemoWindow(showdemo)
        
        ig_Impl:Render()
        sdl.gL_SwapWindow(window);
    end
    
    -- Cleanup
    ig_Impl:destroy()

    sdl.gL_DeleteContext(gl_context);
    sdl.destroyWindow(window);
    sdl.quit();

