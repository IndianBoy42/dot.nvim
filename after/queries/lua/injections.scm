;extends 

((function_call
  name: (_) @_load_identifier
  arguments: (arguments . (string content: _ @lua)))
  (#any-of? @_load_identifier "loadstring" "F"))

; Matches ("%d"):format(value)
(function_call
  (method_index_expression
    table: (parenthesized_expression (string content: _ @injection.content) (#set! injection.language "luap"))
    method: (identifier) @_method))

; Matches fmt("%d", value)
(function_call
  name: (identifier) @_fmt (#any-of? @_fmt "fmt")
  arguments: (arguments (string content: _ @injection.content) (#set! injection.language "luap")))
