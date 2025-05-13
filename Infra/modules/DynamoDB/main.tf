resource  "aws_dynamodb_table" "dynamodb-table" {

    name = var.table_name
    billing_mode   = "PAY_PER_REQUEST"
    hash_key = var.partition_key
    range_key = var.sort_key


    dynamic "attribute" {
        for_each = var.attributes
        content {
            name = attribute.value["name"]
            type = attribute.value["type"]
        }
    }

    dynamic "global_secondary_index"{
        for_each = var.secondary_index ? [1] : []
        content {
            name = "${var.secondary_partitan_key}-${var.secondary_sort_key}-index"
            hash_key = var.secondary_partitan_key
            range_key = var.secondary_sort_key
            projection_type    = "ALL"
        }
    }
    
}

