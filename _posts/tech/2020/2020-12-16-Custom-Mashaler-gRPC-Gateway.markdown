---
layout: post
title:  "gRPC Gateway 를 사용하여 gin 에 띄웠을때 Marshaler 커스텀"
date:   2020-12-16 19:32:00 +0900
categories: tech grpc
permalink: /tech/grpc/:title
---

<h2>
Custom Mashlaer 생성 
</h2>

{% highlight Kconfig %}
type myMarshaler struct {
	JSONPb *runtime.JSONPb
}

func NewMyMarshaler() runtime.ServeMuxOption {
	m := myMarshaler{
		JSONPb: &runtime.JSONPb{OrigName: true, EmitDefaults: true},
	}

	return runtime.WithMarshalerOption(runtime.MIMEWildcard, m)
}

{% endhighlight %}

<h2>
JSONPb interface 구현
</h2>

{% highlight Kconfig %}

func (m customMarshaler) Marshal(v interface{}) ([]byte, error) {
    return m.JSONPb.Marshal(v)
}

func (m myMarshaler) Unmarshal(data []byte, v interface{}) error {
	return m.JSONPb.Unmarshal(data, v)
}

func (m myMarshaler) NewDecoder(r io.Reader) runtime.Decoder {
	return m.JSONPb.NewDecoder(r)
}

func (m myMarshaler) NewEncoder(w io.Writer) runtime.Encoder {
	return m.JSONPb.NewEncoder(w)
}

func (m myMarshaler) ContentType() string {
	return m.JSONPb.ContentType()
}

{% endhighlight %}

필요한 부분 변경

<h2>
mux 생성 시 Custom Marshaler 등록
</h2>

{% highlight Kconfig %}
mux := runtime.NewServeMux(
    NewMyMarshaler(),
)

{% endhighlight %}

<h2>
grpc gate way 등록
</h2>

{% highlight Kconfig %}
opts := []grpc.DialOption{grpc.WithInsecure()}
err := gw.RegisterSampleServiceHandlerFromEndpoint(
    context.Background(),
	mux,
	fmt.Sprintf("%s:%s", host, port),
    opts,
)
if err != nil {
    panic(err)
}

{% endhighlight %}

<h3>
Reference
</h3>

[grpc_gateway] <br/>

[grpc_gateway]: https://github.com/grpc-ecosystem/grpc-gateway

