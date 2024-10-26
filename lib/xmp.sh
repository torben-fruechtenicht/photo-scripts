xmp_file_from_photofile() {
    echo "${1%.*}.xmp"
}

xmp_create_skeleton() {
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

__xml_insert_node() {
    local xpath=$1
    local node_name=$2
    local xmp_file=$3
    xmlstarlet edit --inplace -O \
            -N dc="http://purl.org/dc/elements/1.1/" -N photoshop="http://ns.adobe.com/photoshop/1.0/" \
            -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
            -s "$xpath" -t elem -n "$node_name" "$xmp_file"    
}

__xml_delete_node() {
    local xpath=$1
    local xmp_file=$2
    xmlstarlet edit --inplace -O \
            -N dc="http://purl.org/dc/elements/1.1/" -N photoshop="http://ns.adobe.com/photoshop/1.0/" \
            -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
            -d "$xpath" "$xmp_file"    
}

# FIXME merge with insert node, use optional value p
__xml_insert_node_with_value() {
    local xpath=$1
    local node_name=$2
    local node_value=$3
    local xmp_file=$4
    xmlstarlet edit --inplace -O \
            -N dc="http://purl.org/dc/elements/1.1/" -N photoshop="http://ns.adobe.com/photoshop/1.0/" \
            -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
            -s "$xpath" -t elem -n "$node_name" -v "$node_value" "$xmp_file"
}


# FIXME introduce __xml_upsert_node_with_value

__xml_add_attribute() {
    local xpath=$1
    local attr_name=$2
    local attr_value=$3
    local xmp_file=$4
    xmlstarlet edit --inplace -O \
            -N dc="http://purl.org/dc/elements/1.1/" -N photoshop="http://ns.adobe.com/photoshop/1.0/" \
            -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
            -s "$xpath" -t attr -n "$attr_name" -v "$attr_value" "$xmp_file"
}

__xml_get_value() {
    local xpath=$1
    local xmp_file=$2
    xmlstarlet select \
            -N dc="http://purl.org/dc/elements/1.1/" -N photoshop="http://ns.adobe.com/photoshop/1.0/" \
            -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
            -t -v "$xpath" "$xmp_file" || true   
}

__xml_set_value() {
    local xpath=$1
    local value=$2
    local xmp_file=$3
    xmlstarlet edit --inplace -O \
            -N dc="http://purl.org/dc/elements/1.1/" -N photoshop="http://ns.adobe.com/photoshop/1.0/" \
            -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
            -u "$xpath" -v "$value" "$xmp_file"
}


__xml_xpath_exists() {
    local xpath=$1
    local xmp_file=$2
    test -n "$(xmlstarlet select \
            -N dc="http://purl.org/dc/elements/1.1/" -N photoshop="http://ns.adobe.com/photoshop/1.0/" \
            -N rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" \
            -t -v "$xpath" "$xmp_file")"
}


xmp_set_headline() {
    local xmp_file=$(xmp_file_from_photofile "$1")    
    local headline=$2
    if __xml_xpath_exists "/x:xmpmeta/rdf:RDF/rdf:Description/@photoshop:Headline" "$xmp_file"; then
        __xml_set_value "/x:xmpmeta/rdf:RDF/rdf:Description/@photoshop:Headline" "$headline" "$xmp_file"
    else
        __xml_add_attribute "x:xmpmeta/rdf:RDF/rdf:Description" "photoshop:Headline" "$headline" "$xmp_file"
    fi
}


xmp_set_creator() {
    local xmp_file=$(xmp_file_from_photofile "$1")    
    local creator=$2

    if __xml_xpath_exists "x:xmpmeta/rdf:RDF/rdf:Description/dc:creator/rdf:Seq/rdf:li" "$xmp_file"; then
        __xml_set_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:creator/rdf:Seq/rdf:li" "$creator" "$xmp_file"
    else
        __xml_insert_node "x:xmpmeta/rdf:RDF/rdf:Description" "dc:creator" "$xmp_file"
        __xml_insert_node "x:xmpmeta/rdf:RDF/rdf:Description/dc:creator" "rdf:Seq" "$xmp_file"
        __xml_insert_node_with_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:creator/rdf:Seq" "rdf:li" "$creator" "$xmp_file"
    fi
}


xmp_set_copyright() {
    local xmp_file=$(xmp_file_from_photofile "$1")    
    local copyright_notice=$2

    if __xml_xpath_exists "x:xmpmeta/rdf:RDF/rdf:Description/dc:rights/rdf:Alt/rdf:li" "$xmp_file"; then
        __xml_set_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:rights/rdf:Alt/rdf:li" "$copyright_notice" "$xmp_file"
    else
        __xml_insert_node "x:xmpmeta/rdf:RDF/rdf:Description" "dc:rights" "$xmp_file"
        __xml_insert_node "x:xmpmeta/rdf:RDF/rdf:Description/dc:rights" "rdf:Alt" "$xmp_file"
        __xml_insert_node_with_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:rights/rdf:Alt" "rdf:li" "$copyright_notice" "$xmp_file"
        __xml_add_attribute "x:xmpmeta/rdf:RDF/rdf:Description/dc:rights/rdf:Alt/rdf:li" "xml:lang" "x-default" "$xmp_file"
    fi
}


xmp_get_description() {
    __xml_get_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:description/rdf:Alt/rdf:li" "$1"
}

xmp_set_description() {
    local xmp_file=$(xmp_file_from_photofile "$1")    
    local description=$2

    if __xml_xpath_exists "x:xmpmeta/rdf:RDF/rdf:Description/dc:description/rdf:Alt/rdf:li" "$xmp_file"; then
        __xml_set_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:description/rdf:Alt/rdf:li" "$description" "$xmp_file"
    else
        __xml_insert_node "x:xmpmeta/rdf:RDF/rdf:Description" "dc:description" "$xmp_file"
        __xml_insert_node "x:xmpmeta/rdf:RDF/rdf:Description/dc:description" "rdf:Alt" "$xmp_file"
        __xml_insert_node_with_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:description/rdf:Alt" "rdf:li" "$description" "$xmp_file"
        __xml_add_attribute "x:xmpmeta/rdf:RDF/rdf:Description/dc:description/rdf:Alt/rdf:li" "xml:lang" "x-default" "$xmp_file"
    fi
}


xmp_add_keyword() {
    local xmp_file=$(xmp_file_from_photofile "$1")    
    local keyword=$2   

    if ! __xml_xpath_exists "x:xmpmeta/rdf:RDF/rdf:Description/dc:subject" "$xmp_file"; then
        __xml_insert_node "x:xmpmeta/rdf:RDF/rdf:Description" "dc:subject" "$xmp_file"
        __xml_insert_node "x:xmpmeta/rdf:RDF/rdf:Description/dc:subject" "rdf:Bag" "$xmp_file"
    fi

    if ! __xml_xpath_exists "x:xmpmeta/rdf:RDF/rdf:Description/dc:subject/rdf:Bag/rdf:li[text() ='$keyword']" "$xmp_file"; then
        __xml_insert_node_with_value "x:xmpmeta/rdf:RDF/rdf:Description/dc:subject/rdf:Bag" "rdf:li" "$keyword" "$xmp_file"
    fi
}

xmp_add_keywords_csv() {
    local xmp_file=$(xmp_file_from_photofile "$1")    
    local keywords=$2   

    OLD_IFS=$IFS
    IFS=";"
    for keyword in $keywords; do
        xmp_add_keyword "$xmp_file" "$keyword"
    done
}

xmp_remove_keyword() {
    local xmp_file=$(xmp_file_from_photofile "$1")    
    local keyword=$2   

    if __xml_xpath_exists "x:xmpmeta/rdf:RDF/rdf:Description/dc:subject/rdf:Bag/rdf:li[text() = '$keyword']" "$xmp_file"; then
        __xml_delete_node "x:xmpmeta/rdf:RDF/rdf:Description/dc:subject/rdf:Bag/rdf:li[text() = '$keyword']" "$xmp_file"
    fi
}

xmp_remove_keywords_csv() {
    local xmp_file=$(xmp_file_from_photofile "$1")    
    local keywords=$2   

    OLD_IFS=$IFS
    IFS=";"
    for keyword in $keywords; do
        xmp_remove_keyword "$xmp_file" "$keyword"
    done
    IFS=$OLD_IFS
}