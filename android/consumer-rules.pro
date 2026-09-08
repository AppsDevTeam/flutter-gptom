# Nexgo SDK models are mapped by Gson, which matches JSON keys against field
# names through reflection. The entities carry no @SerializedName, so once R8
# renames their private fields every parse silently yields an object full of
# nulls - a successful register then reports "Register failed (resultCode=null)".
# The same applies the other way round: gson.toJson would emit {"a":...}.
#
# Only the field names have to survive. The classes themselves may still be
# shrunk or renamed, and the public getters the mappers read through are already
# kept by the consumer's own rules.
-keepclassmembers class cn.nexgo.smartconnect.model.** {
    <fields>;
}
