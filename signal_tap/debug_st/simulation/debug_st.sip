set_global_assignment -entity "debug_st" -library "lib_debug_st" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "debug_st" -library "lib_debug_st" -name IP_TOOL_VERSION "19.1"
set_global_assignment -entity "debug_st" -library "lib_debug_st" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_debug_st" -name SPD_FILE [file join $::quartus(sip_path) "../debug_st.spd"]
set_global_assignment -library "lib_debug_st" -name MISC_FILE [file join $::quartus(sip_path) "../../debug_st.qsys"]

set_global_assignment -library "lib_debug_st" -name MISC_FILE [file join $::quartus(sip_path) "debug_st.v"]
set_global_assignment -library "lib_debug_st" -name MISC_FILE [file join $::quartus(sip_path) "submodules/sld_signaltap.v"]
