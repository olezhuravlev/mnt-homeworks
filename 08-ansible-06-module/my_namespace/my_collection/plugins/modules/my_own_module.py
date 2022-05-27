#!/usr/bin/python

# Copyright: (c) 2022, Oleg Zhuravlev <olezhuravlev@gmail.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from pathlib import Path
import ntpath
import os
from os import path

DOCUMENTATION = r'''
---
module: my_own_module

short_description: Create file with supplied content.

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: Module to create file with supplied content.

options:
    path:
        description: Path to create file in.
        required: true
        type: str
    content:
        description: Content to fill the file with.
        required: false
        type: str

# Specify this value according to your collection
# in format of namespace.collection.doc_fragment_name
# extends_documentation_fragment:
#     - my_namespace.my_collection.my_doc_fragment_name

author:
    - Oleg Zhuravlev (@olezhuravlev)
'''

EXAMPLES = r'''
# Pass in a path and file content
- path: Test with a message and changed output
  my_namespace.my_collection.my_test:
    path: hello world
    content: true
# fail the module
- path: Test failure of the module
  my_namespace.my_collection.my_test:
    path: fail me
'''

RETURN = r'''
# These are examples of possible return values, and in general should use other names for return values.
original_message:
    description: The original name param that was passed in.
    type: str
    returned: always
    sample: 'hello world'
message:
    description: The output message that the test module generates.
    type: str
    returned: always
    sample: 'goodbye'
'''

from ansible.module_utils.basic import AnsibleModule


def check_file_needs_update(file_path, content):
  """
  Checks if file exists and has specified content.

  :param file_path: path to the file;
  :param content: content to check in the file for exact match;
  :return: True if file needs to be updated.
  """
  if not path.exists(file_path):
    return True

  # Check file has the same content (the file is one-line!).
  with open(file_path, 'r') as f:
    data = f.read().rstrip()
    if data == content:
      return False
    else:
      return True


def create_file(file_path, content, result):
  """
  Creates file in designated path with provided content.

  :param path: path to the file;
  :param content: content to write into created file;
  :param result: dict for writing result of the operation;
  :return: True if file has been successfully written, False otherwise.
  """
  if not check_file_needs_update(file_path, content):
    result['changed'] = False
    result['message'] = "File is actual"
    return False

  try:
    basepath, filename = ntpath.split(file_path)
    Path(basepath).mkdir(parents=True, exist_ok=True)
    with open(file_path, 'w') as f:
      f.write(content)
      # abspath = os.path.abspath(f)
      real_path = os.path.realpath(f.name)
    result['changed'] = True
    result['message'] = "File written to path {0}".format(real_path)
    return True
  except Exception as e:
    result['changed'] = False
    result['message'] = "Error: {0}".format(e)
    return False

def run_module():

  # define available arguments/parameters a user can pass to the module
  module_args = dict(
      path=dict(type='str', required=True),
      content=dict(type='str', required=False, default="")
  )

  # seed the result dict in the object
  # we primarily care about changed and state
  # changed is if this module effectively modified the target
  # state will include any data that you want your module to pass back
  # for consumption, for example, in a subsequent task
  result = dict(
      changed=False,
      message=''
  )

  # the AnsibleModule object will be our abstraction working with Ansible
  # this includes instantiation, a couple of common attr would be the
  # args/params passed to the execution, as well as if the module
  # supports check mode
  module = AnsibleModule(
      argument_spec=module_args,
      supports_check_mode=True
  )

  # if the user is working with this module in only check mode we do not
  # want to make any changes to the environment, just return the current
  # state with no modifications
  if module.check_mode:
    module.exit_json(**result)


  # use whatever logic you need to determine whether or not this module
  # made any modifications to your target
  create_file(module.params['path'], module.params['content'], result)

  # during the execution of the module, if there is an exception or a
  # conditional state that effectively causes a failure, run
  # AnsibleModule.fail_json() to pass in the message and the result
  if module.params['path'] == 'fail me':
    result['message'] = 'File NOT has been created!'
    module.fail_json(msg='You requested this to fail', **result)

  # in the event of a successful module execution, you will want to
  # simple AnsibleModule.exit_json(), passing the key/value results
  module.exit_json(**result)


def main():
  run_module()


if __name__ == '__main__':
  main()
