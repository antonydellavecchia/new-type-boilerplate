import Oscar.save_internal
import Oscar.load_internal
import Oscar.encodeType
import Oscar.registerSerializationType
import Oscar.@registerSerializationType
import Oscar.PolyRingElem

struct MyNewType{PolyType <: PolyRingElem} 
    p::PolyType

    function MyNewType(p::PolyRingElem)
        return new{typeof(p)}(p)
    end
end
using Oscar

encodeType(MyNewType) = "MyNewtype"
@registerSerializationType(MyNewType, "MyNewType")

function save_internal(s::Oscar.SerializerState, new_elem::MyNewType)
    d = Dict(
        :p => save_internal(s, new_elem.p),
    )
    return d
end

function load_internal(s::Oscar.DeserializerState, ::Type{MyNewType}, dict::Dict)
    p = Oscar.load_internal(s, PolyElem, dict[:p])
    return MyNewType(p)
end

function test(path::String)
    Qx, x = QQ["x"]
    t = MyNewType(x^2)
    save(path, t)
end

 
