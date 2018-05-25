from ansible import errors
from ansible.vars.hostvars import HostVars

def map_hostvars(ansible_hostvars, ansible_groups, group_name, attr):
    if type(ansible_hostvars) != HostVars:
        raise errors.AnsibleFilterError("map_hostvars: The filter expects hostvars as input")

    data = []
    for host in get_attribute(ansible_groups, group_name, "map_hostvars: Failed to get '%s' from groups %s"):
        hostvars = get_attribute(ansible_hostvars, host)
        data.append(get_nested_attribute(hostvars, attr))
    return data

def get_nested_attribute(obj, pointer):
    parts = pointer.split('.')
    final_attribute_index = len(parts) - 1
    current_object = obj
    for i, part in enumerate(parts):
        current_object = get_attribute(current_object, part)
        if i == final_attribute_index: return current_object

def get_attribute(obj, key, message = "map_hostvars: Failed to get '%s' from the dict with the keys %s"):
    try:
       return obj[key]
    except KeyError:
        raise errors.AnsibleFilterError(message % (key, obj.keys()))

class FilterModule (object):
    def filters(self):
        return {"map_hostvars": map_hostvars}
