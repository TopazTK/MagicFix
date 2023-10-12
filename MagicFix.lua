LUAGUI_NAME = "Insta-Magic!"
LUAGUI_AUTH = "TopazTK"
LUAGUI_DESC = "Fixes Magic not appearing in the Command Menu upon receiving. Requires LuaEngine Reborn."

MagicFirst = 0x4460F6
MagicSecond = 0x446131

MagicOld = 0x00
MagicCount = 0x00

function _OnFrame()
    if (EXE_ADDRESS & 0xF0000000) == 0xF0000000 then
        MEMORY_OFFSET = (EXE_ADDRESS & 0xFFFF00000000) + 0x100000000
    end

    MagicRead = ReadInt(MagicFirst) + ReadShort(MagicSecond) 
    if MagicOld < MagicRead then
        MagicCount = 0
        tableMagic = {0x31, 0x33, 0x32, 0x34, 0xAE, 0xB1}
        for i = 0, 5 do
            _magicPoint = CallReturn(0x3C3240, i)

            if _magicPoint ~= 0x00 then     
                _sizeRead = CallReturn(0x39E2F0, MEMORY_OFFSET + _magicPoint + 0x04)  
                _allocMemory = CallReturn(0x150030, _sizeRead)  

                JumpFunction(0x39E4E0, MEMORY_OFFSET + _magicPoint + 0x04, MEMORY_OFFSET + _allocMemory)

                BAR_OFFSET = ReadInt(MEMORY_OFFSET + _allocMemory + 0x08, true)

                PAX_OFFSET = ReadInt(MEMORY_OFFSET + _allocMemory + 0x18, true) - BAR_OFFSET
                MAG_OFFSET = ReadInt(MEMORY_OFFSET + _allocMemory + 0x28, true) - BAR_OFFSET

                WriteLong(0x24BCC7A + (0x50 * i), MEMORY_OFFSET + _magicPoint) 
                WriteLong(0x24BCC32 + (0x50 * i), MEMORY_OFFSET + _allocMemory)
                WriteLong(0x24BCC3A + (0x50 * i), MEMORY_OFFSET + _allocMemory + MAG_OFFSET)
                WriteLong(0x24BCC42 + (0x50 * i), MEMORY_OFFSET + _allocMemory + MAG_OFFSET)
                WriteLong(0x24BCC52 + (0x50 * i), MEMORY_OFFSET + _allocMemory + PAX_OFFSET + 0x10)

                CallFunction(0x2C3D80, EXE_ADDRESS + 0x2A21198 + (0x50 * i), MEMORY_OFFSET + _allocMemory + PAX_OFFSET)

                for z = 0, 5 do
                    MAGIC_COMMAND = ReadShort(0x24AA33A + (0x02 * z))
                    
                    if MAGIC_COMMAND == tableMagic[i + 1] then
                        break
                    elseif MAGIC_COMMAND == 0x00 then
                        WriteByte(0x24AA33A + (0x02 * z), tableMagic[i + 1])
                        break
                    end
                end
                
                MagicCount = MagicCount + 1
            end
        end
        
        WriteArray(EXE_ADDRESS + 0x3C314A, {0x90, 0x90, 0x90, 0x90, 0x90}, true)

        MagicOld = MagicRead
    end
end