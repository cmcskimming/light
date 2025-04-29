local instance_class_types = require("./types")

type InstanceClassname = instance_class_types.InstanceClassname

local instance_classes = {} :: { [InstanceClassname | string]: boolean | nil }

return instance_classes
