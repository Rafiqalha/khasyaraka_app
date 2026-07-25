CREATE TABLE IF NOT EXISTS regencies (
    id          VARCHAR(20) PRIMARY KEY,
    province_id VARCHAR(20) NOT NULL,
    name        VARCHAR(200) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_regencies_province_id ON regencies(province_id);

CREATE TABLE IF NOT EXISTS districts (
    id         VARCHAR(20) PRIMARY KEY,
    regency_id VARCHAR(20) NOT NULL,
    name       VARCHAR(200) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_districts_regency_id ON districts(regency_id);

-- ==================== UNITED STATES ====================
-- California (US-CA)
INSERT INTO regencies (id, province_id, name) VALUES
    ('US-CA-01', 'US-CA', 'Los Angeles County'),
    ('US-CA-02', 'US-CA', 'San Francisco County'),
    ('US-CA-03', 'US-CA', 'San Diego County'),
    ('US-CA-04', 'US-CA', 'Santa Clara County');

INSERT INTO districts (id, regency_id, name) VALUES
    ('US-CA-01-1', 'US-CA-01', 'Los Angeles'),
    ('US-CA-01-2', 'US-CA-01', 'Long Beach'),
    ('US-CA-02-1', 'US-CA-02', 'San Francisco'),
    ('US-CA-02-2', 'US-CA-02', 'Daly City'),
    ('US-CA-03-1', 'US-CA-03', 'San Diego'),
    ('US-CA-03-2', 'US-CA-03', 'Chula Vista'),
    ('US-CA-04-1', 'US-CA-04', 'San Jose'),
    ('US-CA-04-2', 'US-CA-04', 'Sunnyvale');

-- Texas (US-TX)
INSERT INTO regencies (id, province_id, name) VALUES
    ('US-TX-01', 'US-TX', 'Harris County'),
    ('US-TX-02', 'US-TX', 'Dallas County'),
    ('US-TX-03', 'US-TX', 'Travis County'),
    ('US-TX-04', 'US-TX', 'Bexar County');

INSERT INTO districts (id, regency_id, name) VALUES
    ('US-TX-01-1', 'US-TX-01', 'Houston'),
    ('US-TX-01-2', 'US-TX-01', 'Pasadena'),
    ('US-TX-02-1', 'US-TX-02', 'Dallas'),
    ('US-TX-02-2', 'US-TX-02', 'Irving'),
    ('US-TX-03-1', 'US-TX-03', 'Austin'),
    ('US-TX-03-2', 'US-TX-03', 'Round Rock'),
    ('US-TX-04-1', 'US-TX-04', 'San Antonio'),
    ('US-TX-04-2', 'US-TX-04', 'Schertz');

-- New York (US-NY)
INSERT INTO regencies (id, province_id, name) VALUES
    ('US-NY-01', 'US-NY', 'New York County'),
    ('US-NY-02', 'US-NY', 'Kings County'),
    ('US-NY-03', 'US-NY', 'Queens County'),
    ('US-NY-04', 'US-NY', 'Erie County');

INSERT INTO districts (id, regency_id, name) VALUES
    ('US-NY-01-1', 'US-NY-01', 'Manhattan'),
    ('US-NY-01-2', 'US-NY-01', 'Harlem'),
    ('US-NY-02-1', 'US-NY-02', 'Brooklyn'),
    ('US-NY-02-2', 'US-NY-02', 'Williamsburg'),
    ('US-NY-03-1', 'US-NY-03', 'Queens'),
    ('US-NY-03-2', 'US-NY-03', 'Flushing'),
    ('US-NY-04-1', 'US-NY-04', 'Buffalo'),
    ('US-NY-04-2', 'US-NY-04', 'Amherst');

-- Florida (US-FL)
INSERT INTO regencies (id, province_id, name) VALUES
    ('US-FL-01', 'US-FL', 'Miami-Dade County'),
    ('US-FL-02', 'US-FL', 'Orange County'),
    ('US-FL-03', 'US-FL', 'Hillsborough County');

INSERT INTO districts (id, regency_id, name) VALUES
    ('US-FL-01-1', 'US-FL-01', 'Miami'),
    ('US-FL-01-2', 'US-FL-01', 'Hialeah'),
    ('US-FL-02-1', 'US-FL-02', 'Orlando'),
    ('US-FL-02-2', 'US-FL-02', 'Winter Park'),
    ('US-FL-03-1', 'US-FL-03', 'Tampa'),
    ('US-FL-03-2', 'US-FL-03', 'Brandon');

-- Illinois (US-IL)
INSERT INTO regencies (id, province_id, name) VALUES
    ('US-IL-01', 'US-IL', 'Cook County'),
    ('US-IL-02', 'US-IL', 'DuPage County');

INSERT INTO districts (id, regency_id, name) VALUES
    ('US-IL-01-1', 'US-IL-01', 'Chicago'),
    ('US-IL-01-2', 'US-IL-01', 'Evanston'),
    ('US-IL-02-1', 'US-IL-02', 'Naperville'),
    ('US-IL-02-2', 'US-IL-02', 'Wheaton');

-- Washington (US-WA)
INSERT INTO regencies (id, province_id, name) VALUES
    ('US-WA-01', 'US-WA', 'King County'),
    ('US-WA-02', 'US-WA', 'Pierce County');

INSERT INTO districts (id, regency_id, name) VALUES
    ('US-WA-01-1', 'US-WA-01', 'Seattle'),
    ('US-WA-01-2', 'US-WA-01', 'Bellevue'),
    ('US-WA-02-1', 'US-WA-02', 'Tacoma'),
    ('US-WA-02-2', 'US-WA-02', 'Lakewood');

-- Nevada (US-NV)
INSERT INTO regencies (id, province_id, name) VALUES
    ('US-NV-01', 'US-NV', 'Clark County');

INSERT INTO districts (id, regency_id, name) VALUES
    ('US-NV-01-1', 'US-NV-01', 'Las Vegas'),
    ('US-NV-01-2', 'US-NV-01', 'Henderson');

-- Massachusetts (US-MA)
INSERT INTO regencies (id, province_id, name) VALUES
    ('US-MA-01', 'US-MA', 'Suffolk County');

INSERT INTO districts (id, regency_id, name) VALUES
    ('US-MA-01-1', 'US-MA-01', 'Boston'),
    ('US-MA-01-2', 'US-MA-01', 'Cambridge');

-- Georgia (US-GA)
INSERT INTO regencies (id, province_id, name) VALUES
    ('US-GA-01', 'US-GA', 'Fulton County');

INSERT INTO districts (id, regency_id, name) VALUES
    ('US-GA-01-1', 'US-GA-01', 'Atlanta'),
    ('US-GA-01-2', 'US-GA-01', 'Sandy Springs');

-- Colorado (US-CO)
INSERT INTO regencies (id, province_id, name) VALUES
    ('US-CO-01', 'US-CO', 'Denver County');

INSERT INTO districts (id, regency_id, name) VALUES
    ('US-CO-01-1', 'US-CO-01', 'Denver'),
    ('US-CO-01-2', 'US-CO-01', 'Aurora');

-- ==================== SINGAPORE ====================
INSERT INTO regencies (id, province_id, name) VALUES
    ('SG-01-1', 'SG-01', 'Central Area'),
    ('SG-02-1', 'SG-02', 'North East Area'),
    ('SG-03-1', 'SG-03', 'North West Area'),
    ('SG-04-1', 'SG-04', 'South East Area'),
    ('SG-05-1', 'SG-05', 'South West Area');

INSERT INTO districts (id, regency_id, name) VALUES
    ('SG-01-1-1', 'SG-01-1', 'Downtown Core'),
    ('SG-01-1-2', 'SG-01-1', 'Orchard'),
    ('SG-02-1-1', 'SG-02-1', 'Serangoon'),
    ('SG-02-1-2', 'SG-02-1', 'Hougang'),
    ('SG-03-1-1', 'SG-03-1', 'Woodlands'),
    ('SG-03-1-2', 'SG-03-1', 'Yishun'),
    ('SG-04-1-1', 'SG-04-1', 'Bedok'),
    ('SG-04-1-2', 'SG-04-1', 'Tampines'),
    ('SG-05-1-1', 'SG-05-1', 'Jurong East'),
    ('SG-05-1-2', 'SG-05-1', 'Clementi');

-- ==================== MALAYSIA ====================
-- Johor (MY-01)
INSERT INTO regencies (id, province_id, name) VALUES
    ('MY-01-1', 'MY-01', 'Johor Bahru'),
    ('MY-01-2', 'MY-01', 'Batu Pahat'),
    ('MY-01-3', 'MY-01', 'Muar');

INSERT INTO districts (id, regency_id, name) VALUES
    ('MY-01-1-1', 'MY-01-1', 'Johor Bahru City'),
    ('MY-01-1-2', 'MY-01-1', 'Skudai'),
    ('MY-01-2-1', 'MY-01-2', 'Batu Pahat Town'),
    ('MY-01-2-2', 'MY-01-2', 'Yong Peng'),
    ('MY-01-3-1', 'MY-01-3', 'Muar Town'),
    ('MY-01-3-2', 'MY-01-3', 'Pagoh');

-- Selangor (MY-10)
INSERT INTO regencies (id, province_id, name) VALUES
    ('MY-10-1', 'MY-10', 'Petaling'),
    ('MY-10-2', 'MY-10', 'Klang'),
    ('MY-10-3', 'MY-10', 'Gombak');

INSERT INTO districts (id, regency_id, name) VALUES
    ('MY-10-1-1', 'MY-10-1', 'Petaling Jaya'),
    ('MY-10-1-2', 'MY-10-1', 'Subang Jaya'),
    ('MY-10-2-1', 'MY-10-2', 'Klang City'),
    ('MY-10-2-2', 'MY-10-2', 'Port Klang'),
    ('MY-10-3-1', 'MY-10-3', 'Selayang'),
    ('MY-10-3-2', 'MY-10-3', 'Batu Caves');

-- Kuala Lumpur (MY-14)
INSERT INTO regencies (id, province_id, name) VALUES
    ('MY-14-1', 'MY-14', 'Kuala Lumpur City');

INSERT INTO districts (id, regency_id, name) VALUES
    ('MY-14-1-1', 'MY-14-1', 'KLCC'),
    ('MY-14-1-2', 'MY-14-1', 'Bukit Bintang'),
    ('MY-14-1-3', 'MY-14-1', 'Bangsar');

-- Penang (MY-07)
INSERT INTO regencies (id, province_id, name) VALUES
    ('MY-07-1', 'MY-07', 'Timur Laut'),
    ('MY-07-2', 'MY-07', 'Barat Daya');

INSERT INTO districts (id, regency_id, name) VALUES
    ('MY-07-1-1', 'MY-07-1', 'George Town'),
    ('MY-07-1-2', 'MY-07-1', 'Tanjong Tokong'),
    ('MY-07-2-1', 'MY-07-2', 'Bayan Lepas'),
    ('MY-07-2-2', 'MY-07-2', 'Balik Pulau');

-- Sabah (MY-12)
INSERT INTO regencies (id, province_id, name) VALUES
    ('MY-12-1', 'MY-12', 'Kota Kinabalu'),
    ('MY-12-2', 'MY-12', 'Sandakan');

INSERT INTO districts (id, regency_id, name) VALUES
    ('MY-12-1-1', 'MY-12-1', 'Kota Kinabalu City'),
    ('MY-12-1-2', 'MY-12-1', 'Penampang'),
    ('MY-12-2-1', 'MY-12-2', 'Sandakan Town'),
    ('MY-12-2-2', 'MY-12-2', 'Sepilok');

-- Sarawak (MY-13)
INSERT INTO regencies (id, province_id, name) VALUES
    ('MY-13-1', 'MY-13', 'Kuching'),
    ('MY-13-2', 'MY-13', 'Miri');

INSERT INTO districts (id, regency_id, name) VALUES
    ('MY-13-1-1', 'MY-13-1', 'Kuching City'),
    ('MY-13-1-2', 'MY-13-1', 'Padawan'),
    ('MY-13-2-1', 'MY-13-2', 'Miri City'),
    ('MY-13-2-2', 'MY-13-2', 'Lutong');

-- Perak (MY-08)
INSERT INTO regencies (id, province_id, name) VALUES
    ('MY-08-1', 'MY-08', 'Kinta'),
    ('MY-08-2', 'MY-08', 'Larut, Matang and Selama');

INSERT INTO districts (id, regency_id, name) VALUES
    ('MY-08-1-1', 'MY-08-1', 'Ipoh City'),
    ('MY-08-1-2', 'MY-08-1', 'Batu Gajah'),
    ('MY-08-2-1', 'MY-08-2', 'Taiping'),
    ('MY-08-2-2', 'MY-08-2', 'Kamunting');

-- Melaka (MY-04)
INSERT INTO regencies (id, province_id, name) VALUES
    ('MY-04-1', 'MY-04', 'Melaka Tengah');

INSERT INTO districts (id, regency_id, name) VALUES
    ('MY-04-1-1', 'MY-04-1', 'Malacca City'),
    ('MY-04-1-2', 'MY-04-1', 'Ayer Keroh');

-- Pahang (MY-06)
INSERT INTO regencies (id, province_id, name) VALUES
    ('MY-06-1', 'MY-06', 'Kuantan'),
    ('MY-06-2', 'MY-06', 'Cameron Highlands');

INSERT INTO districts (id, regency_id, name) VALUES
    ('MY-06-1-1', 'MY-06-1', 'Kuantan City'),
    ('MY-06-1-2', 'MY-06-1', 'Gebeng'),
    ('MY-06-2-1', 'MY-06-2', 'Tanah Rata'),
    ('MY-06-2-2', 'MY-06-2', 'Brinchang');

-- Kedah (MY-02)
INSERT INTO regencies (id, province_id, name) VALUES
    ('MY-02-1', 'MY-02', 'Kota Setar'),
    ('MY-02-2', 'MY-02', 'Langkawi');

INSERT INTO districts (id, regency_id, name) VALUES
    ('MY-02-1-1', 'MY-02-1', 'Alor Setar'),
    ('MY-02-2-1', 'MY-02-2', 'Kuah');

-- ==================== PHILIPPINES ====================
-- NCR (PH-00)
INSERT INTO regencies (id, province_id, name) VALUES
    ('PH-00-1', 'PH-00', 'Manila'),
    ('PH-00-2', 'PH-00', 'Quezon City'),
    ('PH-00-3', 'PH-00', 'Makati');

INSERT INTO districts (id, regency_id, name) VALUES
    ('PH-00-1-1', 'PH-00-1', 'Ermita'),
    ('PH-00-1-2', 'PH-00-1', 'Binondo'),
    ('PH-00-2-1', 'PH-00-2', 'Diliman'),
    ('PH-00-2-2', 'PH-00-2', 'Cubao'),
    ('PH-00-3-1', 'PH-00-3', 'Makati CBD'),
    ('PH-00-3-2', 'PH-00-3', 'Guadalupe');

-- Central Luzon (PH-03)
INSERT INTO regencies (id, province_id, name) VALUES
    ('PH-03-1', 'PH-03', 'Angeles'),
    ('PH-03-2', 'PH-03', 'Olongapo');

INSERT INTO districts (id, regency_id, name) VALUES
    ('PH-03-1-1', 'PH-03-1', 'Balibago'),
    ('PH-03-1-2', 'PH-03-1', 'Clark Freeport'),
    ('PH-03-2-1', 'PH-03-2', 'Subic Bay');

-- CALABARZON (PH-04)
INSERT INTO regencies (id, province_id, name) VALUES
    ('PH-04-1', 'PH-04', 'Batangas City'),
    ('PH-04-2', 'PH-04', 'Santa Rosa');

INSERT INTO districts (id, regency_id, name) VALUES
    ('PH-04-1-1', 'PH-04-1', 'Batangas Poblacion'),
    ('PH-04-2-1', 'PH-04-2', 'Santa Rosa Poblacion'),
    ('PH-04-2-2', 'PH-04-2', 'Nuvali');

-- Central Visayas (PH-07)
INSERT INTO regencies (id, province_id, name) VALUES
    ('PH-07-1', 'PH-07', 'Cebu City'),
    ('PH-07-2', 'PH-07', 'Mandaue');

INSERT INTO districts (id, regency_id, name) VALUES
    ('PH-07-1-1', 'PH-07-1', 'Cebu City Center'),
    ('PH-07-1-2', 'PH-07-1', 'Lahug'),
    ('PH-07-2-1', 'PH-07-2', 'Mandaue City Center');

-- Davao Region (PH-11)
INSERT INTO regencies (id, province_id, name) VALUES
    ('PH-11-1', 'PH-11', 'Davao City');

INSERT INTO districts (id, regency_id, name) VALUES
    ('PH-11-1-1', 'PH-11-1', 'Davao Poblacion'),
    ('PH-11-1-2', 'PH-11-1', 'Toril');

-- Western Visayas (PH-06)
INSERT INTO regencies (id, province_id, name) VALUES
    ('PH-06-1', 'PH-06', 'Iloilo City'),
    ('PH-06-2', 'PH-06', 'Bacolod');

INSERT INTO districts (id, regency_id, name) VALUES
    ('PH-06-1-1', 'PH-06-1', 'Iloilo City Proper'),
    ('PH-06-2-1', 'PH-06-2', 'Bacolod City Center');

-- ==================== THAILAND ====================
-- Bangkok (TH-10)
INSERT INTO regencies (id, province_id, name) VALUES
    ('TH-10-1', 'TH-10', 'Pathum Wan'),
    ('TH-10-2', 'TH-10', 'Watthana'),
    ('TH-10-3', 'TH-10', 'Chatuchak');

INSERT INTO districts (id, regency_id, name) VALUES
    ('TH-10-1-1', 'TH-10-1', 'Siam'),
    ('TH-10-1-2', 'TH-10-1', 'Ratchaprasong'),
    ('TH-10-2-1', 'TH-10-2', 'Thong Lo'),
    ('TH-10-2-2', 'TH-10-2', 'Ekkamai'),
    ('TH-10-3-1', 'TH-10-3', 'Chatuchak Market'),
    ('TH-10-3-2', 'TH-10-3', 'Ladprao');

-- Chiang Mai (TH-50)
INSERT INTO regencies (id, province_id, name) VALUES
    ('TH-50-1', 'TH-50', 'Mueang Chiang Mai');

INSERT INTO districts (id, regency_id, name) VALUES
    ('TH-50-1-1', 'TH-50-1', 'Old City'),
    ('TH-50-1-2', 'TH-50-1', 'Nimmanhaemin');

-- Phuket (TH-83)
INSERT INTO regencies (id, province_id, name) VALUES
    ('TH-83-1', 'TH-83', 'Mueang Phuket');
INSERT INTO districts (id, regency_id, name) VALUES
    ('TH-83-1-1', 'TH-83-1', 'Patong'),
    ('TH-83-1-2', 'TH-83-1', 'Phuket Town');

-- Chon Buri (TH-20)
INSERT INTO regencies (id, province_id, name) VALUES
    ('TH-20-1', 'TH-20', 'Bang Lamung'),
    ('TH-20-2', 'TH-20', 'Mueang Chon Buri');
INSERT INTO districts (id, regency_id, name) VALUES
    ('TH-20-1-1', 'TH-20-1', 'Pattaya'),
    ('TH-20-1-2', 'TH-20-1', 'Jomtien'),
    ('TH-20-2-1', 'TH-20-2', 'Chon Buri City');

-- ==================== VIETNAM ====================
-- Ho Chi Minh City (VN-40)
INSERT INTO regencies (id, province_id, name) VALUES
    ('VN-40-1', 'VN-40', 'District 1'),
    ('VN-40-2', 'VN-40', 'District 3'),
    ('VN-40-3', 'VN-40', 'District 7');
INSERT INTO districts (id, regency_id, name) VALUES
    ('VN-40-1-1', 'VN-40-1', 'Ben Nghe'),
    ('VN-40-1-2', 'VN-40-1', 'Ben Thanh'),
    ('VN-40-2-1', 'VN-40-2', 'Vo Thi Sau'),
    ('VN-40-3-1', 'VN-40-3', 'Tan Phong'),
    ('VN-40-3-2', 'VN-40-3', 'Phu My Hung');

-- Ha Noi (VN-11)
INSERT INTO regencies (id, province_id, name) VALUES
    ('VN-11-1', 'VN-11', 'Hoan Kiem'),
    ('VN-11-2', 'VN-11', 'Ba Dinh');
INSERT INTO districts (id, regency_id, name) VALUES
    ('VN-11-1-1', 'VN-11-1', 'Hoan Kiem Lake'),
    ('VN-11-1-2', 'VN-11-1', 'Old Quarter'),
    ('VN-11-2-1', 'VN-11-2', 'Ba Dinh Square'),
    ('VN-11-2-2', 'VN-11-2', 'Tay Ho');

-- Da Nang (VN-22)
INSERT INTO regencies (id, province_id, name) VALUES
    ('VN-22-1', 'VN-22', 'Hai Chau'),
    ('VN-22-2', 'VN-22', 'Son Tra');
INSERT INTO districts (id, regency_id, name) VALUES
    ('VN-22-1-1', 'VN-22-1', 'Hai Chau Center'),
    ('VN-22-2-1', 'VN-22-2', 'My Khe Beach');

-- ==================== UNITED KINGDOM ====================
-- England (GB-ENG)
INSERT INTO regencies (id, province_id, name) VALUES
    ('GB-ENG-1', 'GB-ENG', 'Greater London'),
    ('GB-ENG-2', 'GB-ENG', 'Greater Manchester'),
    ('GB-ENG-3', 'GB-ENG', 'West Midlands');
INSERT INTO districts (id, regency_id, name) VALUES
    ('GB-ENG-1-1', 'GB-ENG-1', 'Westminster'),
    ('GB-ENG-1-2', 'GB-ENG-1', 'Camden'),
    ('GB-ENG-2-1', 'GB-ENG-2', 'Manchester City Centre'),
    ('GB-ENG-2-2', 'GB-ENG-2', 'Salford'),
    ('GB-ENG-3-1', 'GB-ENG-3', 'Birmingham City Centre'),
    ('GB-ENG-3-2', 'GB-ENG-3', 'Coventry');

-- Scotland (GB-SCT)
INSERT INTO regencies (id, province_id, name) VALUES
    ('GB-SCT-1', 'GB-SCT', 'City of Edinburgh'),
    ('GB-SCT-2', 'GB-SCT', 'Glasgow City');
INSERT INTO districts (id, regency_id, name) VALUES
    ('GB-SCT-1-1', 'GB-SCT-1', 'Edinburgh Old Town'),
    ('GB-SCT-1-2', 'GB-SCT-1', 'Edinburgh New Town'),
    ('GB-SCT-2-1', 'GB-SCT-2', 'Glasgow City Centre'),
    ('GB-SCT-2-2', 'GB-SCT-2', 'West End');

-- Wales (GB-WLS)
INSERT INTO regencies (id, province_id, name) VALUES
    ('GB-WLS-1', 'GB-WLS', 'Cardiff');
INSERT INTO districts (id, regency_id, name) VALUES
    ('GB-WLS-1-1', 'GB-WLS-1', 'Cardiff City Centre'),
    ('GB-WLS-1-2', 'GB-WLS-1', 'Cardiff Bay');

-- Northern Ireland (GB-NIR)
INSERT INTO regencies (id, province_id, name) VALUES
    ('GB-NIR-1', 'GB-NIR', 'Belfast');
INSERT INTO districts (id, regency_id, name) VALUES
    ('GB-NIR-1-1', 'GB-NIR-1', 'Belfast City Centre'),
    ('GB-NIR-1-2', 'GB-NIR-1', 'Titanic Quarter');
