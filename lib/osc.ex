defmodule OSC do
    def encode([addr|data]) do
        encode_string(addr) <> encode_flags(data) <> encode_data(data)
    end 
        
    def encode_string(msg) do
        len = String.length(msg) 
        # The string portion should always be a multiple of 4 bytes   
        case rem(len, 4) do
            0 -> msg <> <<0,0,0,0>>
            1 -> msg <> <<0,0,0>>
            2 -> msg <> <<0,0>>
            3 -> msg <> <<0>>
        end
    end

    def encode_flags(data) do
        str = Enum.reduce(data, ",", fn(x, acc) -> 
            case x do
                x when is_list(x) -> acc <> "s"
                x when is_integer(x) -> acc <> "i"
                x when is_binary(x) -> acc <> "s"
                x when is_float(x) -> acc <> "f"
            end
        end)
        encode_string(str)
    end

    def encode_data(x) when is_integer(x) do
        << x :: integer-32>>
    end

    def encode_data(x) when is_float(x) do
        << x :: float-32>>
    end

    def encode_data(x) when is_binary(x) do 
        encode_string(x)
    end  

    def encode_data(x) when is_list(x) do 
        Enum.reduce(x, <<>>, fn(curr, acc) -> acc <> encode_data(curr) end)            
    end
end