@tool
extends EditorPlugin

const CLOSING_CHARACTERS: Array[String] = [")", "}", "]", "\'", '\"']

var script_editor: ScriptEditor
var active_code_edit: CodeEdit


func _enter_tree() -> void:
	script_editor = EditorInterface.get_script_editor()
	script_editor.editor_script_changed.connect(on_script_changed)
	update_active_code_edit()


func _exit_tree() -> void:
	disconnect_active_code_edit()
	if script_editor.editor_script_changed.is_connected(on_script_changed):
		script_editor.editor_script_changed.disconnect(on_script_changed)
	script_editor = null


func on_script_changed(script: Script) -> void:
	update_active_code_edit()


func update_active_code_edit() -> void:
	disconnect_active_code_edit()
	
	var current_editor: ScriptEditorBase = script_editor.get_current_editor()
	
	if current_editor:
		if current_editor.get_base_editor() is CodeEdit:
			active_code_edit = current_editor.get_base_editor()
			active_code_edit.gui_input.connect(on_current_code_edit_gui_input)


func on_current_code_edit_gui_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if not event.keycode == KEY_TAB:
			return
		
		if active_code_edit.has_selection():
			return
		
		var carat_line: int = active_code_edit.get_caret_line()
		var carat_column: int = active_code_edit.get_caret_column()
		var current_char: String
		var preceding_char: String
		var current_line_string: String = active_code_edit.get_line(carat_line)
		
		if event.is_released():
			return
		
		if event.is_echo():
			return
		
		if carat_column != 0:
			preceding_char = current_line_string[carat_column - 1]
		
		if event.shift_pressed:
			if not preceding_char:
				return
			
			if preceding_char and preceding_char in CLOSING_CHARACTERS:
				active_code_edit.set_caret_column(carat_column - 1)
				active_code_edit.get_viewport().set_input_as_handled()
			return
		
		if carat_column == len(current_line_string): #last char
			return
		
		current_char = current_line_string[carat_column]
		
		if current_char in CLOSING_CHARACTERS:
			active_code_edit.set_caret_column(carat_column + 1)
			active_code_edit.get_viewport().set_input_as_handled()


func disconnect_active_code_edit() -> void:
	if active_code_edit and active_code_edit.gui_input.is_connected(on_current_code_edit_gui_input):
		active_code_edit.gui_input.disconnect(on_current_code_edit_gui_input)
		active_code_edit = null
		CLOSING_CHARACTERS[1]
