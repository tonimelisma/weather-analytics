declare @wsid varchar(max),
    @latitude decimal,
    @longitude decimal;

declare @counter int = 0

declare ws_cursor cursor for
    select [Weather Station ID], latitude, longitude
    from [Weather Stations] where elevation < 1000;
open ws_cursor;

fetch next
    from ws_cursor into @wsid, @latitude, @longitude;

while @@FETCH_STATUS = 0 begin
    set @counter = @counter + 1;
    print @counter;

    declare @wslocation geography;
    set @wslocation = geography::Point(@latitude, @longitude, 4326);

    declare @city varchar(max), @citylatitude decimal, @citylongitude decimal;

    declare city_cursor cursor for
        select City, Latitude, Longitude from Cities;
    open city_cursor;

    fetch next from city_cursor into @city, @citylatitude, @citylongitude;
    while @@FETCH_STATUS = 0 begin
        declare @citylocation geography, @distance decimal;
        set @citylocation = geography::Point(@citylatitude, @citylongitude, 4326);

        set @distance = @wslocation.STDistance(@citylocation) / 1000;
        if @distance < 100 begin
            insert into [Weather Stations to Cities] (City, [Weather Station ID], Distance)
                values(@city, @wsid, @distance);
            print @wsid + ' is near ' + @city + ': ' + convert(varchar(max), @distance);
        end

        fetch next from city_cursor into @city, @citylatitude, @citylongitude;
    end;

    close city_cursor;
    deallocate city_cursor;

    fetch next
        from ws_cursor into @wsid, @latitude, @longitude;
end;

close ws_cursor;
deallocate ws_cursor;