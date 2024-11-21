### Overview
![Application components](./diagrams/moving-part.drawio.png)

### Database
![Normalization example](./diagrams/normalization-example.drawio.png)

### API
Zoning questions for the source table:
- What zoning districts does this tax lot have?

Zoning questions for the normalized table
From the perspective of the tax lot
- What zoning districts does this tax lot have?
  - Implemented: 
  - [tax-lots](https://zoning-api.nycplanningdigital.com/api/tax-lots)
  - [tax-lots/{bbl}/zoning-districts](https://zoning-api.nycplanningdigital.com/api/tax-lots/4004297501/zoning-districts)
- Where does the tax lot intersect with those zoning districts?
- How much does a zoning district overlap with a tax lot?
From the perspective of the zoning district
- What tax lots does this zoning district have?
- Is the tax lot fully within the zoning district?
- What kind of development is allowed within this zoning district?
  - Implemented: [/zoning-districts/{id}/classes](https://zoning-api.nycplanningdigital.com/api/zoning-districts/94a33fe6-717f-4eed-b393-1fab3d85a1a6/classes) 
    - 94a33fe6-717f-4eed-b393-1fab3d85a1a6
    - a68c90ff-ca49-42b2-807f-021e34bdbb79
- What kind of development is allowed within this tax lot?
    - Implemented: [tax-lots/{bbl}/zoning-districts/classes](https://zoning-api.nycplanningdigital.com/api/tax-lots/4004297501/zoning-districts/classes)

### Client

![user interface example](./diagrams/client-example.png)
