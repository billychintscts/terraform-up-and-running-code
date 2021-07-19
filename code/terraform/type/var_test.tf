


# if not number, 
# This default value is not compatible with the variable's type constraint: a number is
/*
variable "number_example" {
  description = "An example of a number variable in Terraform"
  type        = number
  default     = 42
}
*/ 
/* this is allowed
variable "string_example" {
  description = "An example of a string in Terraform"
  type        = string
  default     = 2
}
*/ 
# list
# type list (not specify = any)
/* pure string
variable "list_example" {
  description = "An example of a list in Terraform"
  type        = list
  default     = ["a", "b", "c"]
}
*/
/* mix string and number, boolean - allowed
variable "list_example" {
  description = "An example of a list in Terraform"
  type        = list
  default     = ["a", 2, true]
}
*/ 
 
 
/* this is allowed
variable "list_example" {
  description = "An example of a list in Terraform"
  type        = list(string)
  default     = ["a", false, true]
}
*/
/* example list number allowed
variable "list_example2" {
  description = "An example of a list of number in Terraform"
  type        = list(number)
  default     = [1, 2, 3]
}
*/
/* this is allow
variable "list_boolean" {
  description = "An example of a list of boolean in Terraform"
  type        = list(bool)
  default     = [true, false, true]
}
*/
/* map with all string
variable "map_example" {
  description = "An example of a map in Terraform"
  type        = map(string)

  default = {
    key1 = "value1"
    key2 = "value2"
    key3 = "value3"
  }
}
*/

variable "object_example" {
  description = "An example of a structural type in Terraform"
  type        = object({
    name    = string
    age     = number
    tags    = list(string)
    enabled = bool
  })
    default = {
    name    = "value1"
    age     = 42
    tags    = ["a", "b", "c"]
    enabled = true
  }
}
/* object example with error
variable "object_example_with_error" {
  description = "An example of a structural type in Terraform with an error"
  type        = object({
    name    = string
    age     = number
    tags    = list(string)
    enabled = bool
  })
    default = {
    name    = "value1"
    age     = 42
    tags    = ["a", "b", "c"]
    enabled = "invalid"
  }
}

the error is 
Error: Invalid default value for variable
 
   on var_test.tf line 96, in variable "object_example_with_error":
   96:     default = {
  97:     name    = "value1"
   98:     age     = 42
   99:     tags    = ["a", "b", "c"]
  100:     enabled = "invalid"
 101:   }
 
 This default value is not compatible with the variable's type constraint: a bool is required.
*/


