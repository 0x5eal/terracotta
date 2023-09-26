local Utils = require("../utils/misc")
local JSONEncode = require("@lune/net").jsonEncode

export type Generators = "retain_lines" | "dense" | "readable"
export type Rules =
	"compute_expression"
	| "convert_index_to_field"
	| "convert_local_function_to_assign"
	| "convert_require"
	| "filter_after_early_return"
	| "group_local_assignment"
	| "inject_global_value"
	| "remove_comments"
	| "remove_compound_assignment"
	| "remove_empty_do"
	| "remove_function_call_parens"
	| "remove_method_definition"
	| "remove_nil_declaration"
	| "remove_spaces"
	| "remove_unused_if_branch"
	| "remove_unused_while"
	| "rename_variables"

export type Options = {
	generator: Generators?,
	excludes: { string }?,
	requireMode: "path"?,
	moduleFolderName: string?,
	sources: { [string]: string }?,
	rules: {
		Rules | {
			rule: Rules,
			identifier: string,
			value: any,
		} | {
			rule: Rules,
			[any]: any,
		}
	}?,
}

return function(opts: Options): string
	local generator: Generators = opts.generator or "retain_lines"
	local encodedExcludes = JSONEncode(opts.excludes)
	local excludes = (encodedExcludes == "null" and '["@lune/**"]') or encodedExcludes
	local requireMode = opts.requireMode or "path"
	local moduleFolderName = opts.moduleFolderName or "init"
	local sources = JSONEncode(opts.sources or { ["@terracotta"] = "./.terracotta" })
	local encodedRules = JSONEncode(opts.rules)
	local rules = (encodedRules == "null" and "[]") or encodedRules

	local template = [[{
generator: "${generator}",
      
bundle: {
          modules_identifier: "__TERRACOTTA__",
          excludes: ${excludes},
      
          require_mode: {
            name: "${requireMode}",
            module_folder_name: "${moduleFolderName}",
            sources: ${sources}
          }
        },
        rules: ${rules}
}]]

	return Utils.Format(template, {
		generator = generator,
		excludes = excludes,
		requireMode = requireMode,
		moduleFolderName = moduleFolderName,
		sources = sources,
		rules = rules,
	})
end
