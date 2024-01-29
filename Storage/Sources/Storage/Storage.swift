@attached(memberAttribute)
public macro storage() = #externalMacro(module: "StorageMacros", type: "StorageMacro")

@attached(peer)
public macro nonstorage() = #externalMacro(module: "StorageMacros", type: "NonStorageMacro")
