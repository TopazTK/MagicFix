LUAGUI_NAME = "Insta-Magic!"
LUAGUI_AUTH = "TopazTK"
LUAGUI_DESC = "Fixes Magic not appearing in the Command Menu upon receiving. Requires LuaEngine Reborn."

MagicFirst = 0x4460F6
MagicSecond = 0x446131
LoadByte = 0x0453B82

MagicOld = 0x00
MagicCount = 0x00

MagicList = {}

function _OnFrame()
    if (EXE_ADDRESS & 0xF0000000) == 0xF0000000 then
        MEMORY_OFFSET = (EXE_ADDRESS & 0xFFFF00000000) + 0x100000000
    end

    MagicRead = ReadInt(MagicFirst) + ReadShort(MagicSecond)
    
    if ReadByte(LoadByte) == 0x00 and MagicList[1] ~= nil then
        print("")
        ConsolePrint("Resetting Magic Memory!", 1)
        MagicList = {}
    end

    if MagicOld ~= MagicRead then
        MagicCount = 0
        tableMagic = {0x31, 0x33, 0x32, 0x34, 0xAE, 0xB1}
        
        for i = 0, 5 do
            _magicPoint = CallReturn(0x3C3240, i)

            if _magicPoint ~= 0x00 then     

                _readString = ReadString(MEMORY_OFFSET + _magicPoint + 0x04, 0x20, true)

                if ReadLong(0x24BCC7A + (0x50 * i)) == MEMORY_OFFSET + _magicPoint then
                    goto continue
                end

                print("")
                ConsolePrint("Magic Name: " .. _readString, 0)
                
                _sizeRead = CallReturn(0x39E2F0, MEMORY_OFFSET + _magicPoint + 0x04)  
                _allocMemory = CallReturn(0x150030, _sizeRead + 0x800)  

                ConsolePrint("Allocated Region: 0x" .. string.format("%x", MEMORY_OFFSET + _allocMemory), 0)

                JumpFunction(0x39E4E0, MEMORY_OFFSET + _magicPoint + 0x04, MEMORY_OFFSET + _allocMemory)

                ConsolePrint("Loaded BAR to: 0x" .. string.format("%x", MEMORY_OFFSET + _allocMemory), 0)

                BAR_OFFSET = ReadInt(MEMORY_OFFSET + _allocMemory + 0x08, true)

                PAX_OFFSET = ReadInt(MEMORY_OFFSET + _allocMemory + 0x18, true) - BAR_OFFSET
                MAG_OFFSET = ReadInt(MEMORY_OFFSET + _allocMemory + 0x28, true) - BAR_OFFSET

                WriteLong(0x24BCC7A + (0x50 * i), MEMORY_OFFSET + _magicPoint) 
                WriteLong(0x24BCC32 + (0x50 * i), MEMORY_OFFSET + _allocMemory)
                WriteLong(0x24BCC3A + (0x50 * i), MEMORY_OFFSET + _allocMemory + MAG_OFFSET)
                WriteLong(0x24BCC42 + (0x50 * i), MEMORY_OFFSET + _allocMemory + MAG_OFFSET)
                WriteLong(0x24BCC52 + (0x50 * i), MEMORY_OFFSET + _allocMemory + PAX_OFFSET + 0x10)

                ConsolePrint("Magic Details at: 0x" .. string.format("%x", BASE_ADDRESS + 0x24BCC32 + (0x50 * i)), 0)

                EXEC_OFFSET = EXE_ADDRESS + 0x2A21198 + (0x50 * i)

                for p = 1, 6 do
                    if MagicList[p] == EXEC_OFFSET then
                        break
                    end

                    if MagicList[p] == nil then
                        MagicList[p] = EXEC_OFFSET
                        break
                    end
                end

                ::continue::
            end
        end

        print("")
        WriteLong(0x24AA33A, 0x00)

        MAGIC_OFFSET = 0x00

        for i = 0, 5 do
            _magicPoint = CallReturn(0x3C3240, i)
            
            if _magicPoint ~= 0x00 then
                WriteByte(0x24AA33A + (0x02 * MAGIC_OFFSET), tableMagic[i + 1])
                ConsolePrint("Command Written to: 0x" .. string.format("%x", BASE_ADDRESS + 0x24AA33A + (0x02 * MAGIC_OFFSET)), 1)
                MAGIC_OFFSET = MAGIC_OFFSET + 0x01
            end
        end

        print("")
        
        for i = 1, 6 do
            if MagicList[i] ~= nil then
                BAR_OFFSET = ReadLong(MagicList[i] - 0x18, true)
                
                CallFunction(0x2C1AB0, MagicList[i])
                CallFunction(0x2C3D80, MagicList[i], BAR_OFFSET + 0x40)

                ConsolePrint("Loaded PAX at: 0x" .. string.format("%x", BAR_OFFSET + 0x40) .. " for 0x" .. string.format("%x", MagicList[i]), 1)
            end
        end

        WriteArray(EXE_ADDRESS + 0x3C314A, {0x90, 0x90, 0x90, 0x90, 0x90}, true)

        MagicOld = MagicRead
    end
end