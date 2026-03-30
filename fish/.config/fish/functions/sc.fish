function sc
    aws events list-rules --name-prefix prod --query 'Rules[].{Name:Name,State:State,Schedule:ScheduleExpression}' --output table $argv
end
