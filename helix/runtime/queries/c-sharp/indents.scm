; C# indent queries for Helix

[
  (block)
  (declaration_list)
  (enum_member_declaration_list)
  (switch_body)
  (anonymous_object_creation_expression)
  (initializer_expression)
  (expression_statement)
  (arrow_expression_clause)
  (switch_expression)
  (switch_expression_arm)
  (argument_list)
  (parameter_list)
  (bracket_parameter_list)
  (attribute_argument_list)
  (type_argument_list)
  (type_parameter_list)
  (base_list)
  (array_rank_specifier)
  (accessor_list)
] @indent

[
  "}"
  ")"
  "]"
] @outdent

; Single-statement bodies without braces
(if_statement
  consequence: (_) @indent
  (#not-kind-eq? @indent "block")
  (#set! "scope" "all"))
(else_clause
  (_) @indent
  (#not-kind-eq? @indent "block")
  (#not-kind-eq? @indent "if_statement")
  (#set! "scope" "all"))
(while_statement
  body: (_) @indent
  (#not-kind-eq? @indent "block")
  (#set! "scope" "all"))
(for_statement
  body: (_) @indent
  (#not-kind-eq? @indent "block")
  (#set! "scope" "all"))
(for_each_statement
  body: (_) @indent
  (#not-kind-eq? @indent "block")
  (#set! "scope" "all"))
