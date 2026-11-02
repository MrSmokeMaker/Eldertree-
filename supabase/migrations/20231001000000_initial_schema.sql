CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE trees (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tree_id UUID NOT NULL REFERENCES trees(id) ON DELETE CASCADE,
    first_name TEXT NOT NULL,
    last_name TEXT,
    gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'other')),
    birth_date DATE,
    death_date DATE,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE relationships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    member1_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    member2_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    relationship_type TEXT NOT NULL CHECK (relationship_type IN ('parent', 'spouse')),
    is_active BOOLEAN NOT NULL DEFAULT true,
    end_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (member1_id, member2_id, relationship_type)
);

CREATE TABLE facts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    category TEXT NOT NULL CHECK (category IN ('birthplace', 'occupation', 'trait', 'phrase', 'story', 'custom')),
    value TEXT NOT NULL,
    fact_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE timeline_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    member_id UUID NOT NULL REFERENCES members(id) ON DELETE CASCADE,
    event_date DATE,
    title TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    audio_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tier_level TEXT NOT NULL CHECK (tier_level IN ('free', 'standard', 'pro')) DEFAULT 'free',
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id)
);

ALTER TABLE trees ENABLE ROW LEVEL SECURITY;
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE facts ENABLE ROW LEVEL SECURITY;
ALTER TABLE timeline_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own trees" 
ON trees FOR ALL USING (auth.uid() = owner_id);

CREATE POLICY "Users can manage members of their trees" 
ON members FOR ALL USING (
    EXISTS (SELECT 1 FROM trees WHERE trees.id = members.tree_id AND trees.owner_id = auth.uid())
);

CREATE POLICY "Users can manage relationships" 
ON relationships FOR ALL USING (
    EXISTS (
        SELECT 1 FROM members 
        JOIN trees ON trees.id = members.tree_id 
        WHERE members.id = relationships.member1_id AND trees.owner_id = auth.uid()
    )
);

CREATE POLICY "Users can manage facts" 
ON facts FOR ALL USING (
    EXISTS (
        SELECT 1 FROM members 
        JOIN trees ON trees.id = members.tree_id 
        WHERE members.id = facts.member_id AND trees.owner_id = auth.uid()
    )
);

CREATE POLICY "Users can manage timeline events" 
ON timeline_events FOR ALL USING (
    EXISTS (
        SELECT 1 FROM members 
        JOIN trees ON trees.id = members.tree_id 
        WHERE members.id = timeline_events.member_id AND trees.owner_id = auth.uid()
    )
);

CREATE POLICY "Users can manage own subscription" 
ON subscriptions FOR ALL USING (auth.uid() = user_id);

INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('media', 'media', true) ON CONFLICT DO NOTHING;
INSERT INTO storage.buckets (id, name, public) VALUES ('audio', 'audio', false) ON CONFLICT DO NOTHING;

CREATE POLICY "Avatar images are publicly accessible." ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "Users can upload avatars" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');
CREATE POLICY "Users can update their avatars" ON storage.objects FOR UPDATE USING (bucket_id = 'avatars' AND auth.role() = 'authenticated');
CREATE POLICY "Users can delete their avatars" ON storage.objects FOR DELETE USING (bucket_id = 'avatars' AND auth.role() = 'authenticated');

CREATE POLICY "Media images are publicly accessible." ON storage.objects FOR SELECT USING (bucket_id = 'media');
CREATE POLICY "Users can upload media" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'media' AND auth.role() = 'authenticated');
CREATE POLICY "Users can update their media" ON storage.objects FOR UPDATE USING (bucket_id = 'media' AND auth.role() = 'authenticated');
CREATE POLICY "Users can delete their media" ON storage.objects FOR DELETE USING (bucket_id = 'media' AND auth.role() = 'authenticated');

CREATE POLICY "Users can manage audio" ON storage.objects FOR ALL USING (bucket_id = 'audio' AND auth.role() = 'authenticated');
