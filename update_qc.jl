using DataFrames
using CSV

const catalog_csv = "catalog_blue.csv"
const allowed_keys = ["variable_id", "experiment_id", "time_range", "member_id"]

function string_to_vector(x)
    strip.(split(strip(x, ['[',']',' ']),','))
end

function body_to_dict(input_string)
    y = split.(strip.(split(input_string,'\n')),':')
    y = y[length.(y) .== 2]
    y = permutedims(hcat(y...))
    y = strip.(y)
    truths = [(x in allowed_keys) for x in y[:,1]]
    y = y[truths,:]
    return Dict([(String(y[i,1]),String.(string_to_vector(y[i,2]))) for i in 1:size(y)[1]])
end

function find_rows(df, columns)
    truths = ones(Bool, size(df)[1])
    for (k,v) in columns
        if k == "experiment_id"
            subtruths = zeros(Bool, size(df)[1])
            for x in v
                subtruths = (subtruths .| occursin.(x,df[!,k]))
            end
            truths = (truths .& subtruths)
        else
            subtruths = zeros(Bool, size(df)[1])
            for x in v
                subtruths = (subtruths .| (df[!,k] .== x))
            end
            truths = (truths .& subtruths)
        end
    end
    return truths
end

function update_qc!(df, columns, qc_status, who_qc)
    truths = find_rows(df, columns)
    df[truths,:pass_qc] .= qc_status
    df[truths,:who_qc] .= who_qc
    return df[truths,:]
end

function main(x)
    df = DataFrame(CSV.File(catalog_csv; types=Dict("who_qc" => String)))

    username = x[1]
    param_dict = body_to_dict(x[2])

    update_qc!(df, param_dict, true, username)
    CSV.write(catalog_csv, df)
end

main(ARGS)