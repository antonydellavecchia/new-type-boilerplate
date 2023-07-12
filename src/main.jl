using Oscar
import Oscar.save_internal
import Oscar.load_internal
import Oscar.encodeType


struct MyNewType
    p::PolyElem
    v::Vector
end

struct MyNewType
    p::PolyElem
    v::Vector
end

encodeType(T::Type{MyNewType}) = "MyNewType"

function save_internal(s::Oscar.SerializerState, new_elem::MyNewType)
    d = Dict(
        :p => save_internal(s, new_elem.p),
        :v => save_internal(s, new_elem.v)
    )
    return d
end

Qx, x = QQ["x"]
t = MyNewType(x^2, [1, 1])

save("./test.json", t)

 
