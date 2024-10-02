xmp_file_from_photofile() {
    local photofile_filename=$(basename "$1")
    echo "${photofile_filename%.*}.xmp"
}

create_blank_xmp() {
    local xmp_file=$(xmp_file_from_photofile "$1")
    cat <<-EOF > "$xmp_file"
<x:xmpmeta xmlns:x="adobe:ns:meta/" x:xmptk="XMP Core 4.4.0-Exiv2">
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
        <rdf:Description rdf:about=""
            xmlns:dc="http://purl.org/dc/elements/1.1/"
            xmlns:photoshop="http://ns.adobe.com/photoshop/1.0/">
        </rdf:Description>
    </rdf:RDF>
</x:xmpmeta>
EOF
    echo "$xmp_file"
}


__xml_starlet_insert_node() {
    local xpath=$1
    local node_name=$2
    local xmp_file=$3
    xmlstarlet ed --inplace -O \
            -N dc="http://purl.org/dc/elements/1.1/" -N photoshop="http://ns.adobe.com/photoshop/1.0/" \
            -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
            -s "$xpath" -t elem -n "$node_name" "$xmp_file"    
}

__xml_starlet_insert_node_with_value() {
    local xpath=$1
    local node_name=$2
    local node_value=$3
    local xmp_file=$4
    xmlstarlet ed --inplace -O \
            -N dc="http://purl.org/dc/elements/1.1/" -N photoshop="http://ns.adobe.com/photoshop/1.0/" \
            -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
            -s "$xpath" -t elem -n "$node_name" -v "$node_value" "$xmp_file"
}

__xml_starlet_add_attribute() {
    local xpath=$1
    local attr_name=$2
    local attr_value=$3
    local xmp_file=$4
    xmlstarlet ed --inplace -O \
            -N dc="http://purl.org/dc/elements/1.1/" -N photoshop="http://ns.adobe.com/photoshop/1.0/" \
            -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
            -s "$xpath" -t attr -n "$attr_name" -v "$attr_value" "$xmp_file"
}

__xml_starlet_add_attribute() {
    local xpath=$1
    local attr_name=$2
    local attr_value=$3
    local xmp_file=$4
    xmlstarlet ed --inplace -O \
            -N dc="http://purl.org/dc/elements/1.1/" -N photoshop="http://ns.adobe.com/photoshop/1.0/" \
            -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
            -s "$xpath" -t attr -n "$attr_name" -v "$attr_value" "$xmp_file"
}

__xmlstartlet_get_value() {
    local xpath=$1
    local xmp_file=$2
    xmlstarlet sel \
            -N dc="http://purl.org/dc/elements/1.1/" -N photoshop="http://ns.adobe.com/photoshop/1.0/" \
            -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
            -t -v "$xpath" "$xmp_file" || true   
}

__xml_starlet_set_value() {
    local xpath=$1
    local value=$2
    local xmp_file=$3
    xmlstarlet ed --inplace -O \
            -N dc="http://purl.org/dc/elements/1.1/" -N photoshop="http://ns.adobe.com/photoshop/1.0/" \
            -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
            -u "$xpath" -v "$value" "$xmp_file"
}

__xml_xpath_exists() {
    local xpath=$1
    local xmp_file=$2
    xmlstarlet sel \
            -N dc="http://purl.org/dc/elements/1.1/" -N photoshop="http://ns.adobe.com/photoshop/1.0/" \
            -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
            -t -v "$xpath" "$xmp_file" > /dev/null  
}


write_xmp_headline() {
    local xmp_file=$(xmp_file_from_photofile "$1")    
    local headline=$2
    if $(__xml_xpath_exists "/x:xmpmeta/rdf:RDF/rdf:Description/@photoshop:Headline" "$xmp_file"); then
        __xml_starlet_set_value "/x:xmpmeta/rdf:RDF/rdf:Description/@photoshop:Headline" "$headline" "$xmp_file"
    else
        __xml_starlet_add_attribute "x:xmpmeta/rdf:RDF/rdf:Description" "photoshop:Headline" "$headline" "$xmp_file"
    fi
}

write_xmp_creator() {
    local xmp_file=$(xmp_file_from_photofile "$1")    
    local creator=$2

    if $(__xml_xpath_exists "x:xmpmeta/rdf:RDF/rdf:Description/dc:creator/rdf:Seq/rdf:li" "$xmp_file"); then
        __xml_starlet_set_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:creator/rdf:Seq/rdf:li" "$creator" "$xmp_file"
    else
        __xml_starlet_insert_node "x:xmpmeta/rdf:RDF/rdf:Description" "dc:creator" "$xmp_file"
        __xml_starlet_insert_node "x:xmpmeta/rdf:RDF/rdf:Description/dc:creator" "rdf:Seq" "$xmp_file"
        __xml_starlet_insert_node_with_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:creator/rdf:Seq" "rdf:li" "$creator" "$xmp_file"
    fi
}

write_xmp_copyright() {
    local xmp_file=$(xmp_file_from_photofile "$1")    
    local copyright_notice=$2

    if $(__xml_xpath_exists "x:xmpmeta/rdf:RDF/rdf:Description/dc:rights/rdf:Alt/rdf:li" "$xmp_file"); then
        __xml_starlet_set_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:rights/rdf:Alt/rdf:li" "$copyright_notice" "$xmp_file"
    else
        __xml_starlet_insert_node "x:xmpmeta/rdf:RDF/rdf:Description" "dc:rights" "$xmp_file"
        __xml_starlet_insert_node "x:xmpmeta/rdf:RDF/rdf:Description/dc:rights" "rdf:Alt" "$xmp_file"
        __xml_starlet_insert_node_with_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:rights/rdf:Alt" "rdf:li" "$copyright_notice" "$xmp_file"
        __xml_starlet_add_attribute "x:xmpmeta/rdf:RDF/rdf:Description/dc:rights/rdf:Alt/rdf:li" "xml:lang" "x-default" "$xmp_file"
    fi
}

xmp_get_description() {
    __xmlstartlet_get_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:description/rdf:Alt/rdf:li" "$1"
}

write_xmp_description() {
    local xmp_file=$(xmp_file_from_photofile "$1")    
    local description=$2

    if $(__xml_xpath_exists "x:xmpmeta/rdf:RDF/rdf:Description/dc:description/rdf:Alt/rdf:li" "$xmp_file"); then
        __xml_starlet_set_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:description/rdf:Alt/rdf:li" "$description" "$xmp_file"
    else
        __xml_starlet_insert_node "x:xmpmeta/rdf:RDF/rdf:Description" "dc:description" "$xmp_file"
        __xml_starlet_insert_node "x:xmpmeta/rdf:RDF/rdf:Description/dc:description" "rdf:Alt" "$xmp_file"
        __xml_starlet_insert_node_with_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:description/rdf:Alt" "rdf:li" "$description" "$xmp_file"
        __xml_starlet_add_attribute "x:xmpmeta/rdf:RDF/rdf:Description/dc:description/rdf:Alt/rdf:li" "xml:lang" "x-default" "$xmp_file"
    fi
}

write_xmp_keywords_from_csv_string() {
    local xmp_file=$(xmp_file_from_photofile "$1")    
    local keywords_csv=$2   

    if $(__xml_xpath_exists "x:xmpmeta/rdf:RDF/rdf:Description/dc:subject/rdf:Bag/rdf:li" "$xmp_file"); then
        echo "Keywords entry exists in $xmp_file" >&2
        exit 1
    else
        __xml_starlet_insert_node "x:xmpmeta/rdf:RDF/rdf:Description" "dc:subject" "$xmp_file"
        __xml_starlet_insert_node "x:xmpmeta/rdf:RDF/rdf:Description/dc:subject" "rdf:Bag" "$xmp_file"

        OLD_IFS=$IFS
	    IFS=";"
	    for keyword in $keywords_csv; do
            __xml_starlet_insert_node_with_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:subject/rdf:Bag" "rdf:li" "$keyword" "$xmp_file"
	    done
	    IFS=$OLD_IFS
    fi
}

add_xmp_keyword() {
    local xmp_file=$(xmp_file_from_photofile "$1")    
    local keyword=$2   

    if $(__xml_xpath_exists "x:xmpmeta/rdf:RDF/rdf:Description/dc:subject/rdf:Bag/rdf:li[$keyword]" "$xmp_file"); then
        echo "Keyword $keyword exists in $xmp_file" >&2
        exit 1
    else
        __xml_starlet_insert_node_with_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:subject/rdf:Bag" "rdf:li" "$keyword" "$xmp_file"
    fi
}