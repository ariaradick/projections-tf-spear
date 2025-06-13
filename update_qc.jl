using DataFrames
using CSV

const catalog_csv = "catalog_blue.csv"
const allowed_keys = ["variable_id", "experiment_id", "time_range", "member_id"]

function string_to_vector(x)
    strip.(split(strip(x, ['[',']',' ']),','))
end

function parse_body(input_string, cat_df)
    allowed_vars = unique(cat_df[!,:variable_id])

    var_dict = Dict{Symbol,Vector{String}}()
    y = strip.(split(input_string,'\n'))
    y = y[[3,7,11,15]]

    if y[1] in allowed_vars
        var_dict[:variable_id] = [y[1]]
    else
        error("Invalid variable name entered.")
    end

    if y[2] == "Historical"
        var_dict[:experiment_id] = ["SPEAR_c192_o1_Hist_AllForc_IC1921_K50"]
    elseif y[2] == "SSP585"
        var_dict[:experiment_id] = ["SPEAR_c192_o1_Scen_SSP585_IC2011_K50"]
    end
    truths = (cat_df[!,:variable_id] .== var_dict[:variable_id]) .& 
             (cat_df[!,:experiment_id] .== var_dict[:experiment_id])

    allowed_times = unique(cat_df[truths,:time_range])

    if (y[3] ≠ "_No response_")
        time_ranges = string_to_vector(y[3])
        for t in time_ranges
            if t ∉ allowed_times
                error("Invalid time range entered.")
            end
        end
        var_dict[:time_range] = time_ranges
    end

    if y[4] == "Yes"
        pass_qc = true
    elseif y[4] == "No"
        pass_qc = false
    end

    return var_dict, pass_qc
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
    param_dict, pass_qc = parse_body(x[2], df)

    update_qc!(df, param_dict, pass_qc, username)
    CSV.write(catalog_csv, df)
end

main(ARGS)