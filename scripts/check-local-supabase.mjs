import { createClient } from '@supabase/supabase-js'

const url = process.env.SUPABASE_URL
const key = process.env.SUPABASE_PUBLISHABLE_KEY
const email = process.env.SUPABASE_TEST_EMAIL
const password = process.env.SUPABASE_TEST_PASSWORD

if (!url || !key || !email || !password) {
  throw new Error('Missing required environment variables')
}

const supabase = createClient(url, key)

const { error: signInError } = await supabase.auth.signInWithPassword({
  email,
  password,
})

if (signInError) {
  throw signInError
}

const { data, error } = await supabase
  .schema('entities')
  .from('entity')
  .select('id, entity_type, working_label')
  .order('working_label')

if (error) {
  throw error
}

console.table(data)
