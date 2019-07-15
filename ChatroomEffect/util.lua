
log_fatal = function(msg, ...) aegisub.log(0, msg, ...) end
log_error = function(msg, ...) aegisub.log(1, msg, ...) end
log_warning = function(msg, ...) aegisub.log(2, msg, ...) end
log_hint = function(msg, ...) aegisub.log(3, msg, ...) end
log_debug = function(msg, ...) aegisub.log(4, msg, ...) end
log_trace = function(msg, ...) aegisub.log(5, msg, ...) end
