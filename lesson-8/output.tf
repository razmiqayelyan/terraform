# aws_users  = ["Razo", "Ozar", "Zoar", "Arzo", "Roza", "Zaro", "Raz"]

output "create_iam_user_map" {
  value = {
    for user in aws_iam_user.users:
    user.unique_id => user.id
  }
}
# expected output
# Outputs:

# create_iam_user_map = {
#   "AIDAVDWSMJ4O4EFHWCJMH" = "Roza"
#   "AIDAVDWSMJ4O5SRB4D54J" = "Arzo"
#   "AIDAVDWSMJ4OQQ3DRTWTI" = "Zoar"
#   "AIDAVDWSMJ4ORHRI7QA6G" = "Ozar"
#   "AIDAVDWSMJ4OVTASGG65G" = "Zaro"
#   "AIDAVDWSMJ4OW46GAZDJB" = "Razo"
# }


output "custom_if_lenght" {
  value = [
    for x in aws_iam_user.users:
    x.name
    if length(x.name) == 3
  ]
}

# expected output
# custom_if_lenght = [
#   "Raz",
# ]